const { ipcRenderer } = require('electron');

let selectedFolderPath = null;
let scannedFiles = null;
let previewedChanges = null;

// DOM Elements
const selectFolderBtn = document.getElementById('selectFolder');
const selectedPathSpan = document.getElementById('selectedPath');
const apiVersionInput = document.getElementById('apiVersion');
const scanFilesBtn = document.getElementById('scanFiles');
const filesSummaryDiv = document.getElementById('filesSummary');
const changesPreviewDiv = document.getElementById('changesPreview');
const applyChangesBtn = document.getElementById('applyChanges');
const deployChangesBtn = document.getElementById('deployChanges');
const resultsDiv = document.getElementById('results');
const loadingOverlay = document.getElementById('loadingOverlay');

// Event Listeners
selectFolderBtn.addEventListener('click', selectFolder);
scanFilesBtn.addEventListener('click', scanFiles);
applyChangesBtn.addEventListener('click', applyChanges);
deployChangesBtn.addEventListener('click', deployChanges);

// Utility Functions
function showLoading(show = true) {
    if (show) {
        loadingOverlay.classList.add('active');
    } else {
        loadingOverlay.classList.remove('active');
    }
}

function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `result-item ${type === 'error' ? 'error' : ''}`;
    notification.textContent = message;
    resultsDiv.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.parentNode.removeChild(notification);
        }
    }, 5000);
}

// Main Functions
async function selectFolder() {
    try {
        const result = await ipcRenderer.invoke('select-folder');
        
        if (!result.canceled && result.filePaths.length > 0) {
            selectedFolderPath = result.filePaths[0];
            selectedPathSpan.textContent = selectedFolderPath;
            scanFilesBtn.disabled = false;
            
            // Clear previous results
            filesSummaryDiv.innerHTML = '';
            changesPreviewDiv.innerHTML = '';
            applyChangesBtn.disabled = true;
            deployChangesBtn.disabled = true;
        }
    } catch (error) {
        console.error('Error selecting folder:', error);
        showNotification('Error al seleccionar la carpeta: ' + error.message, 'error');
    }
}

async function scanFiles() {
    if (!selectedFolderPath) {
        showNotification('Por favor selecciona una carpeta primero', 'error');
        return;
    }

    const apiVersion = apiVersionInput.value.trim();
    if (!apiVersion) {
        showNotification('Por favor ingresa una versión de API', 'error');
        return;
    }

    showLoading(true);
    
    try {
        // Escanear archivos
        const files = await ipcRenderer.invoke('scan-files', selectedFolderPath);
        
        if (files.error) {
            throw new Error(files.error);
        }
        
        scannedFiles = files;
        
        // Mostrar resumen de archivos encontrados
        displayFilesSummary(files);
        
        // Preview de cambios
        const changes = await ipcRenderer.invoke('preview-changes', selectedFolderPath, files, apiVersion);
        
        if (changes.error) {
            throw new Error(changes.error);
        }
        
        previewedChanges = changes;
        displayChangesPreview(changes);
        
        if (changes.length > 0) {
            applyChangesBtn.disabled = false;
        } else {
            showNotification('No se encontraron archivos que necesiten actualización', 'success');
        }
        
    } catch (error) {
        console.error('Error scanning files:', error);
        showNotification('Error al escanear archivos: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

function displayFilesSummary(files) {
    const totalFiles = files.classes.length + files.triggers.length + files.lwc.length;
    
    filesSummaryDiv.innerHTML = `
        <div class="summary-stats">
            <div class="stat-item">
                <div class="stat-number">${files.classes.length}</div>
                <div class="stat-label">Clases Apex</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${files.triggers.length}</div>
                <div class="stat-label">Triggers</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${files.lwc.length}</div>
                <div class="stat-label">Archivos LWC</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${totalFiles}</div>
                <div class="stat-label">Total</div>
            </div>
        </div>
        <p><strong>Archivos encontrados:</strong> ${totalFiles} archivos en total</p>
    `;
}

function displayChangesPreview(changes) {
    if (changes.length === 0) {
        changesPreviewDiv.innerHTML = '<p>No hay archivos que necesiten actualización de API.</p>';
        return;
    }
    
    let html = '<h3>Archivos que serán modificados:</h3>';
    
    changes.forEach(change => {
        html += `
            <div class="change-item">
                <div class="file-info">
                    <div class="file-name">${change.file}</div>
                    <div class="file-type">${change.type}</div>
                </div>
                <div class="version-change">
                    ${change.currentVersion} <span class="arrow">→</span> ${change.newVersion}
                </div>
            </div>
        `;
    });
    
    changesPreviewDiv.innerHTML = html;
}

async function applyChanges() {
    if (!previewedChanges || previewedChanges.length === 0) {
        showNotification('No hay cambios para aplicar', 'error');
        return;
    }
    
    showLoading(true);
    
    try {
        const results = await ipcRenderer.invoke('apply-changes', selectedFolderPath, previewedChanges);
        
        if (results.error) {
            throw new Error(results.error);
        }
        
        // Mostrar resultados
        let successCount = 0;
        let errorCount = 0;
        
        results.forEach(result => {
            if (result.success) {
                successCount++;
            } else {
                errorCount++;
            }
        });
        
        showNotification(`✅ Cambios aplicados exitosamente: ${successCount} archivos actualizados`, 'success');
        
        if (errorCount > 0) {
            showNotification(`⚠️ Errores en ${errorCount} archivos`, 'error');
        }
        
        // Habilitar deploy button
        deployChangesBtn.disabled = false;
        
        // Deshabilitar apply button
        applyChangesBtn.disabled = true;
        
    } catch (error) {
        console.error('Error applying changes:', error);
        showNotification('Error al aplicar cambios: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

async function deployChanges() {
    if (!selectedFolderPath) {
        showNotification('No hay carpeta seleccionada', 'error');
        return;
    }
    
    showLoading(true);
    showNotification('🚀 Iniciando deploy a Salesforce...', 'success');
    
    try {
        const result = await ipcRenderer.invoke('deploy-changes', selectedFolderPath);
        
        // Mostrar resultado del deploy
        let resultHtml = `
            <div class="result-item ${result.success ? '' : 'error'}">
                <h4>${result.success ? '✅ Deploy Exitoso' : '❌ Deploy Fallido'}</h4>
                <div class="deploy-output">${result.output}</div>
                ${result.error ? `<div class="deploy-output">${result.error}</div>` : ''}
            </div>
        `;
        
        resultsDiv.innerHTML += resultHtml;
        
        if (result.success) {
            showNotification('🎉 Deploy completado exitosamente', 'success');
        } else {
            showNotification('❌ Error en el deploy. Revisa la salida para más detalles.', 'error');
        }
        
    } catch (error) {
        console.error('Error deploying changes:', error);
        showNotification('Error durante el deploy: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    console.log('Salesforce API Updater initialized');
}); 