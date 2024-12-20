-- Crear base de datos
CREATE DATABASE DB_ECOMMERCE;

-- Crear esquema 'dbo' dentro de la base de datos DB_ECOMMERCE
CREATE SCHEMA dbo;

--CARGA DE DATOS STAGE 

CREATE TABLE dbo.STG_VENTAS(
	VentaID smallint NOT NULL,
	ClienteID smallint NOT NULL,
	ProductoID smallint NOT NULL,
	Cantidad smallint NOT NULL,
	FechaVenta date NOT NULL,
	Region varchar(50) NOT NULL
)
 
COPY dbo.STG_VENTAS from 'C:\datos\ventas.csv' DELIMITER ',' CSV HEADER; 

CREATE TABLE dbo.STG_CLIENTES(
	ClienteID int NULL,
	NombreCliente varchar(100) NULL,
	Email varchar(100) NULL,
	Telefono varchar(20) NULL,
	Direccion varchar(200) NULL
) 

COPY dbo.STG_CLIENTES from 'C:\datos\clientes.csv' DELIMITER ',' CSV HEADER; 

CREATE TABLE dbo.STG_PRODUCTOS(
	ProductoID smallint NOT NULL,
	NombreProducto varchar(50) NOT NULL,
	Categoria varchar(50) NOT NULL,
	PrecioUnitario float NOT NULL
)

COPY dbo.STG_PRODUCTOS from 'C:\datos\productos.csv' DELIMITER ',' CSV HEADER; 

--CREACION DE TABLAS 

CREATE TABLE dbo.Clientes (
    ClienteId int PRIMARY KEY,  
    NombreCliente VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion VARCHAR(200)
)

CREATE TABLE dbo.Categorias(
	CategoriaId SERIAL PRIMARY KEY,
	NombreCategoria varchar(50) NULL
)

CREATE TABLE dbo.Regiones(
	RegionId SERIAL PRIMARY KEY,
	NombreRegion varchar(50) NULL
)

CREATE TABLE dbo.Productos(
	ProductoId int PRIMARY KEY, 
	NombreProducto varchar(50) NULL,
	CategoriaId int NULL,
	precioUnitario decimal(10, 2) NULL
) 

CREATE TABLE dbo.Vendedores(
	VendedorId SERIAL PRIMARY KEY, 
	NombreVendedor varchar(50) NULL
)

CREATE TABLE dbo.Ventas(
	VentasId int PRIMARY KEY,
	clienteId int NULL,
	fechaVenta date NULL,
	regionId int NULL,
	vendedorId int NULL
) 

CREATE TABLE dbo.DetallesVenta(
	DetalleVentaId SERIAL PRIMARY KEY,
	VentasId int,
	productoId int NULL,
	cantidad int NULL,
	precioUnitario decimal(10, 2) NULL,
	totalVenta decimal(14, 2) NULL
)

ALTER TABLE dbo.Productos
ADD CONSTRAINT fk_categoria
FOREIGN KEY (CategoriaId)
REFERENCES dbo.Categorias (CategoriaId)

ALTER TABLE dbo.Ventas
ADD CONSTRAINT fk_clientes
FOREIGN KEY (clienteId)
REFERENCES dbo.Clientes (ClienteId)

ALTER TABLE dbo.Ventas
ADD CONSTRAINT fk_region
FOREIGN KEY (regionId)
REFERENCES dbo.Regiones (regionId)

ALTER TABLE dbo.Ventas 
ADD CONSTRAINT fk_vendedor 
FOREIGN KEY(vendedorId)
REFERENCES dbo.Vendedores (VendedorId) 

ALTER TABLE dbo.DetallesVenta 
ADD CONSTRAINT fk_producto 
FOREIGN KEY(productoId)
REFERENCES dbo.Productos (ProductoId)

ALTER TABLE dbo.DetallesVenta 
ADD CONSTRAINT fk_ventas 
FOREIGN KEY(VentasId)
REFERENCES dbo.Ventas (VentasId) 

-- CARGA DE DATOS EN TABLAS FINALES
-- REGIONES 

MERGE INTO dbo.Regiones AS T
USING ( 
	SELECT DISTINCT TRIM(Region) Region 
	FROM dbo.STG_VENTAS
) AS S ON (T.NombreRegion=S.Region)
WHEN NOT MATCHED THEN INSERT(NombreRegion) VALUES(S.Region) 

-- CATEGORIAS 

MERGE INTO dbo.Categorias AS T
USING (
	SELECT DISTINCT TRIM(Categoria) Categoria  
	FROM dbo.STG_PRODUCTOS
) AS S ON (T.NombreCategoria=S.Categoria)
WHEN NOT MATCHED THEN INSERT (NombreCategoria) VALUES(S.Categoria) 

-- PRODUCTOS 

MERGE INTO dbo.Productos AS T
USING (
	SELECT A.ProductoId
		  ,TRIM(A.NombreProducto) NombreProducto
		  ,B.CategoriaId
		  ,CAST(A.PrecioUnitario AS DECIMAL(10,2)) PrecioUnitario
	FROM DBO.STG_PRODUCTOS A
	LEFT JOIN dbo.Categorias B 
	ON (TRIM(A.Categoria) = B.NombreCategoria) 
	ORDER BY A.ProductoId
) AS S ON (T.ProductoID=S.ProductoID)
WHEN NOT MATCHED THEN INSERT (ProductoId, NombreProducto, CategoriaId, PrecioUnitario)          
         VALUES (S.ProductoID, S.NombreProducto, S.CategoriaId, S.PrecioUnitario)

-- CLIENTES 
MERGE INTO dbo.Clientes AS T
USING (
 SELECT A.ClienteId ClienteId
    ,TRIM(A.NombreCliente) NombreCliente
    ,TRIM(A.Email) Email
    ,TRIM(A.Telefono) Telefono
    ,TRIM(A.Direccion) Direccion
 FROM DBO.STG_CLIENTES A 
 ORDER BY A.ClienteId, nombrecliente asc
) AS S ON (T.ClienteId=S.ClienteId)
WHEN NOT MATCHED THEN INSERT (ClienteId, NombreCliente,
     Email, Telefono, Direccion) VALUES (S.ClienteId, S.NombreCliente,
     S.Email, S.Telefono, S.Direccion)

-- VENTAS 
MERGE INTO dbo.Ventas AS T
USING (
 SELECT A.VentaID    VentasId
       ,B.ClienteID 
       ,A.FechaVenta FechaVenta
       ,C.RegionId
      FROM dbo.STG_VENTAS A
 LEFT JOIN dbo.Clientes   B ON (A.ClienteID = B.ClienteId)
 LEFT JOIN dbo.Regiones   C ON (A.Region = C.NombreRegion)    
  GROUP BY A.VentaID    
       ,B.ClienteID 
       ,A.FechaVenta 
       ,C.RegionId   
) AS S ON (T.VentasID=S.VentasID)
WHEN NOT MATCHED THEN INSERT (VentasID, ClienteID, FechaVenta, RegionId, VendedorId) 
	VALUES(VentasId, ClienteId, FechaVenta, RegionId, null) 

-- DETALLE VENTAS 
MERGE INTO dbo.DetallesVenta AS T
USING (
 SELECT 
	A.VentaID,
	B.ProductoID,
	A.Cantidad,
	B.precioUnitario as PrecioUnitario,
	A.Cantidad * B.precioUnitario as TotalVenta
    FROM dbo.STG_VENTAS A
 	LEFT JOIN dbo.Productos B ON (A.ProductoId = B.ProductoId)
) AS S ON (T.VentasID=S.VentaID)
WHEN NOT MATCHED THEN INSERT (VentasID, productoId, Cantidad, precioUnitario, totalVenta) 
	VALUES(VentaId, ProductoId, Cantidad, PrecioUnitario, TotalVenta)
