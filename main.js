const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs-extra');
const { spawn } = require('child_process');
const glob = require('glob');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false,
            enableRemoteModule: true
        },
        icon: path.join(__dirname, 'assets', 'icon.png')
    });

    mainWindow.loadFile('index.html');
    
    if (process.argv.includes('--dev')) {
        mainWindow.webContents.openDevTools();
    }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

// IPC Handlers
ipcMain.handle('select-folder', async () => {
    const result = await dialog.showOpenDialog(mainWindow, {
        properties: ['openDirectory'],
        title: 'Selecciona la carpeta del proyecto Salesforce'
    });
    return result;
});

ipcMain.handle('scan-files', async (event, folderPath) => {
    try {
        const files = {
            classes: [],
            triggers: [],
            lwc: []
        };
        
        // Buscar archivos .cls (Apex Classes)
        const classFiles = glob.sync('**/*.cls', { cwd: folderPath });
        files.classes = classFiles;
        
        // Buscar archivos .trigger (Apex Triggers)
        const triggerFiles = glob.sync('**/*.trigger', { cwd: folderPath });
        files.triggers = triggerFiles;
        
        // Buscar archivos .js en LWC
        const lwcFiles = glob.sync('**/lwc/**/*.js', { cwd: folderPath });
        files.lwc = lwcFiles;
        
        return files;
    } catch (error) {
        console.error('Error scanning files:', error);
        return { error: error.message };
    }
});

ipcMain.handle('preview-changes', async (event, folderPath, files, newApiVersion) => {
    try {
        const changes = [];
        
        for (const file of [...files.classes, ...files.triggers]) {
            const filePath = path.join(folderPath, file);
            const content = await fs.readFile(filePath, 'utf8');
            const apiVersionMatch = content.match(/apiVersion\s*=\s*(\d+(\.\d+)?)/);
            
            if (apiVersionMatch) {
                const currentVersion = apiVersionMatch[1];
                if (currentVersion !== newApiVersion) {
                    changes.push({
                        file,
                        currentVersion,
                        newVersion: newApiVersion,
                        type: file.endsWith('.cls') ? 'Apex Class' : 'Apex Trigger'
                    });
                }
            }
        }
        
        return changes;
    } catch (error) {
        console.error('Error previewing changes:', error);
        return { error: error.message };
    }
});

ipcMain.handle('apply-changes', async (event, folderPath, changes) => {
    try {
        const results = [];
        
        for (const change of changes) {
            const filePath = path.join(folderPath, change.file);
            let content = await fs.readFile(filePath, 'utf8');
            
            // Reemplazar la versión de API
            content = content.replace(
                /apiVersion\s*=\s*\d+(\.\d+)?/,
                `apiVersion = ${change.newVersion}`
            );
            
            await fs.writeFile(filePath, content, 'utf8');
            results.push({ file: change.file, success: true });
        }
        
        return results;
    } catch (error) {
        console.error('Error applying changes:', error);
        return { error: error.message };
    }
});

ipcMain.handle('deploy-changes', async (event, folderPath) => {
    return new Promise((resolve) => {
        const sfdx = spawn('sfdx', ['force:source:push'], { 
            cwd: folderPath,
            shell: true 
        });
        
        let output = '';
        let error = '';
        
        sfdx.stdout.on('data', (data) => {
            output += data.toString();
        });
        
        sfdx.stderr.on('data', (data) => {
            error += data.toString();
        });
        
        sfdx.on('close', (code) => {
            resolve({
                success: code === 0,
                output,
                error,
                code
            });
        });
    });
}); 