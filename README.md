# 👞 calzado_db — Sistema de Gestión para Empresa de Calzado

![SQL Server](https://img.shields.io/badge/Database-Microsoft%20SQL%20Server-red?style=for-the-badge&logo=microsoftsqlserver)
![T-SQL](https://img.shields.io/badge/Language-T--SQL-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

## 📌 Descripción del Proyecto

Este proyecto consiste en el diseño, modelado e implementación de una base de datos relacional para una empresa ecuatoriana dedicada a la comercialización de calzado al por mayor y menor a nivel nacional. 

La solución abarca desde el modelado lógico/físico hasta la automatización con **T-SQL** (Procedimientos Almacenados, Triggers y Vistas), garantizando integridad referencial, transaccionalidad (ACID), seguridad basada en roles y trazabilidad mediante tablas de auditoría.

---

## 🗂️ Módulos del Sistema

* **🛒 Ventas y Facturación:** Registro de ventas (mayoreo/menudeo), detalle de facturación y aplicación de promociones.
* **📦 Inventario y Logística:** Control de stock por sucursal, registro de movimientos y gestión de devoluciones.
* **👥 Clientes y Proveedores:** Directorio centralizado de clientes con validación RUC/Cédula y proveedores por ciudad[cite: 1].
* **🏢 Sucursales y Personal:** Asignación de empleados a puntos de venta físicos a nivel nacional[cite: 1].
* **🔒 Auditoría y Seguridad:** Bitácoras de cambios automáticas y gestión de accesos según roles[cite: 1].

---

## 🛠️ Arquitectura y Objetos T-SQL

* **Modelado Relacional:** 15 tablas normalizadas en Tercera Forma Normal (3FN)[cite: 1].
* **Procedimientos Almacenados (SPs):** Transacciones atómicas (`BEGIN TRAN`, `COMMIT`, `ROLLBACK`) con manejo de errores mediante `TRY...CATCH` para ventas, gestión de catálogo y altas de personal[cite: 1].
* **Triggers Automáticos:**
  * Control estricto de stock para evitar valores negativos.
  * Reingreso automático de inventario al procesar devoluciones.
  * Registro de auditoría ante cambios de precios en el catálogo.
  * Bitácora de accesos y movimientos.
* **Seguridad (RBAC):** Definición de roles (`Administrador`, `Gerente`, `Cajero`, `Vendedor`, `Auditor`) con permisos granulares[cite: 1].
