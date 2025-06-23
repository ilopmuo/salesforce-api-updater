# 🔄 Salesforce API Updater

Aplicación de escritorio para actualizar masivamente las versiones de API de clases Apex, triggers y componentes LWC en proyectos de Salesforce.

## ✨ Características

- 🎯 **Interfaz intuitiva**: GUI moderna y fácil de usar
- 📁 **Selector de carpetas**: Navega y selecciona tu proyecto Salesforce
- 🔍 **Escaneo automático**: Encuentra archivos .cls, .trigger y .js de LWC
- 👀 **Preview de cambios**: Ve exactamente qué archivos serán modificados
- ⚡ **Actualización masiva**: Cambia todas las versiones de API de una vez
- 🚀 **Deploy integrado**: Despliega cambios directamente desde la app
- 📊 **Estadísticas**: Ve cuántos archivos de cada tipo fueron encontrados
- ✅ **Resultados detallados**: Seguimiento completo del proceso

## 📋 Requisitos Previos

1. **Node.js** (versión 16 o superior)
2. **Salesforce CLI** (para función de deploy)
3. **Git** (opcional, para clonar el repositorio)

### Instalación de Salesforce CLI

```bash
# Windows
npm install @salesforce/cli --global

# macOS/Linux
npm install @salesforce/cli --global
```

## 🚀 Instalación

### Opción 1: Clonar el repositorio

```bash
git clone https://github.com/ilopmuo/salesforce-api-updater.git
cd salesforce-api-updater
npm install
```

### Opción 2: Descargar ZIP

1. Descarga el archivo ZIP del proyecto
2. Extrae el contenido
3. Abre terminal en la carpeta extraída
4. Ejecuta `npm install`

## 🎮 Uso

### Ejecutar en modo desarrollo

```bash
npm start
```

### Construir aplicación

```bash
# Para Windows
npm run build-win

# Para macOS
npm run build-mac

# Para Linux
npm run build-linux

# Para todas las plataformas
npm run build
```

## 📖 Guía de Uso

### Paso 1: Seleccionar Proyecto
1. Haz clic en "Seleccionar Carpeta del Proyecto"
2. Navega a la carpeta raíz de tu proyecto Salesforce
3. Selecciona la carpeta que contiene tus archivos `.cls`, `.trigger` o LWC

### Paso 2: Configurar Versión de API
1. Ingresa la nueva versión de API (ej: `59.0`)
2. Haz clic en "Escanear Archivos"

### Paso 3: Revisar Cambios
1. Revisa el resumen de archivos encontrados
2. Ve el preview de cambios que se aplicarán
3. Verifica que los cambios sean correctos

### Paso 4: Aplicar Cambios
1. Haz clic en "Aplicar Cambios" para actualizar los archivos
2. Opcionalmente, haz clic en "Deploy a Salesforce" para desplegar

## 📁 Estructura de Archivos Soportados

La aplicación busca y actualiza los siguientes tipos de archivos:

### Apex Classes (*.cls)
```apex
/**
 * @description Mi clase de ejemplo
 */
public class MiClase {
    // La aplicación actualizará esta línea:
    // apiVersion = 58.0  →  apiVersion = 59.0
}
```

### Apex Triggers (*.trigger)
```apex
/**
 * @description Mi trigger de ejemplo
 */
trigger MiTrigger on Account (before insert) {
    // La aplicación actualizará esta línea:
    // apiVersion = 58.0  →  apiVersion = 59.0
}
```

### LWC JavaScript (*.js)
```javascript
import { LightningElement } from 'lwc';

/**
 * @description Mi componente LWC
 */
export default class MiComponente extends LightningElement {
    // La aplicación buscará y actualizará metadatos de API
}
```

## ⚙️ Configuración Avanzada

### Personalizar Versiones de API

Puedes modificar el valor por defecto en `renderer.js`:

```javascript
// Línea ~15
<input type="text" id="apiVersion" placeholder="59.0" value="59.0">
```

### Añadir Nuevos Tipos de Archivo

Para soportar nuevos tipos de archivo, modifica `main.js`:

```javascript
// En la función scan-files
const newFileType = glob.sync('**/*.extension', { cwd: folderPath });
files.newType = newFileType;
```

## 🔧 Solución de Problemas

### La aplicación no encuentra archivos
- ✅ Verifica que estés seleccionando la carpeta raíz del proyecto
- ✅ Asegúrate de que los archivos tengan las extensiones correctas (.cls, .trigger, .js)
- ✅ Revisa que los archivos contengan la declaración `apiVersion = X.X`

### El deploy falla
- ✅ Verifica que Salesforce CLI esté instalado: `sfdx --version`
- ✅ Asegúrate de estar autenticado: `sfdx force:auth:list`
- ✅ Verifica que la carpeta sea un proyecto SFDX válido

### Errores de permisos
- ✅ Ejecuta como administrador (Windows) o con `sudo` (macOS/Linux)
- ✅ Verifica permisos de escritura en la carpeta del proyecto

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

Si encuentras algún problema o tienes sugerencias:

1. Abre un [Issue](https://github.com/ilopmuo/salesforce-api-updater/issues)
2. Describe el problema detalladamente
3. Incluye información de tu sistema operativo y versión de Node.js

## 🙏 Agradecimientos

- Salesforce por proporcionar herramientas de desarrollo excelentes
- La comunidad de Electron por hacer posible las aplicaciones de escritorio con JavaScript
- Todos los contribuidores que hacen este proyecto mejor

---

Hecho con ❤️ para la comunidad de Salesforce 