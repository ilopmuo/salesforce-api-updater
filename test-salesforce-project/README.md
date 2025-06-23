# 🧪 Test Salesforce Project

Este es un proyecto de **prueba** para testing del **Salesforce API Updater**.

## 📁 Contenido del Proyecto

### 🔧 Clases Apex (4 archivos)
- **AccountHelper.cls** - API Version: `50.0`
- **ContactService.cls** - API Version: `55.0`
- **OpportunityManager.cls** - API Version: `48.0`
- **DataService.cls** - API Version: `52.0`

### ⚡ Triggers (2 archivos)
- **AccountTrigger.trigger** - API Version: `45.0`
- **OpportunityTrigger.trigger** - API Version: `56.0`

## 🎯 Propósito

Este proyecto contiene **diferentes versiones de API** para probar que la aplicación **Salesforce API Updater** funcione correctamente:

1. **Escanea** todos los archivos correctamente
2. **Detecta** las diferentes versiones de API
3. **Muestra preview** de los cambios
4. **Actualiza** masivamente a la versión objetivo
5. **Mantiene** la integridad de los archivos

## 🚀 Cómo Usar

1. **Abre** tu aplicación Salesforce API Updater
2. **Selecciona** esta carpeta (`test-salesforce-project`)
3. **Ingresa** la versión de API objetivo (ej: `59.0`)
4. **Haz clic** en "Escanear Archivos"
5. **Revisa** el preview de cambios
6. **Aplica** los cambios

## ✅ Resultado Esperado

Deberías ver **6 archivos** que serán modificados:
- `AccountHelper.cls-meta.xml` (50.0 → 59.0)
- `ContactService.cls-meta.xml` (55.0 → 59.0)
- `OpportunityManager.cls-meta.xml` (48.0 → 59.0)
- `DataService.cls-meta.xml` (52.0 → 59.0)
- `AccountTrigger.trigger-meta.xml` (45.0 → 59.0)
- `OpportunityTrigger.trigger-meta.xml` (56.0 → 59.0)

## 📋 Verificación

Después de aplicar los cambios, todos los archivos `-meta.xml` deberían tener:
```xml
<apiVersion>59.0</apiVersion>
```

## 🔄 Resetear Test

Para volver a las versiones originales, simplemente usa Git:
```bash
git checkout -- .
```

---

**Nota**: Este es un proyecto de prueba. No intentes hacer deploy a una org real de Salesforce. 