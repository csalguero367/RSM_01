-- CREAR BASE DE DATOS VENTASRSM EN SQL SERVER
	CREATE DATABASE [VentasRSM]
	
--CREACION DE TABLA CLIENTES
CREATE TABLE [dbo].[Clientes](
	[ClienteId] [int] NOT NULL,
	[NombreCliente] [varchar](100) NULL,
	[email] [varchar](100) NULL,
	[telefono] [varchar](20) NULL,
	[direccion] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

---CREACION DE TABLA PRODUCTOS

CREATE TABLE [dbo].[Productos](
	[ProductoId] [int] NOT NULL,
	[NombreProducto] [varchar](100) NULL,
	[CategoriaId] [int] NULL,
	[precioUnitario] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING OFF
ALTER TABLE [dbo].[Productos]  WITH CHECK ADD  CONSTRAINT [FK__Productos__Categ__656C112C] FOREIGN KEY([CategoriaId])
REFERENCES [dbo].[Categorias] ([CategoriaId])
ALTER TABLE [dbo].[Productos] CHECK CONSTRAINT [FK__Productos__Categ__656C112C]

--Se considero que la tabla ventas deberia dividirse en una tabla Encabezado y otra detalleVentas
-- Se cargo los datos proporcionados de ventas en una tabla temporal llamada Tmp_Ventas 

--CREACION TABLA TEMPORAL  Tmp_Ventas

CREATE TABLE #tMP_Ventas(
	[VentasId] [int] NOT NULL,
	[ClienteId] [int] NULL,
	[ProductoId] [int] NULL,
	[Cantidad] [int] NULL,
	[fechaVenta] [date] NULL,
	[regionId] [int] NULL)

-- CREAR TABLA ENCABEZADO DE VENTAS

CREATE TABLE [dbo].[Ventas](
	[VentasId] [int] NOT NULL,
	[clienteId] [int] NULL,
	[fechaVenta] [date] NULL,
	[regionId] [int] NULL,
	[vendedorId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[VentasId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD FOREIGN KEY([clienteId])
REFERENCES [dbo].[Clientes] ([ClienteId])
ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD FOREIGN KEY([regionId])
REFERENCES [dbo].[Regiones] ([RegionId])
ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD FOREIGN KEY([vendedorId])
REFERENCES [dbo].[Vendedores] ([VendedorId])

--CREAR TABLA DETALLE DE VENTAS 
CREATE TABLE [dbo].[DetallesVenta](
	[DetalleVentaId] [int] IDENTITY(1,1) NOT NULL,
	[VentasId] [int] NOT NULL,
	[productoId] [int] NULL,
	[cantidad] [int] NULL,
	[precioUnitario] [decimal](10, 2) NULL,
	[totalVenta] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[DetalleVentaId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[DetallesVenta]  WITH CHECK ADD FOREIGN KEY([productoId])
REFERENCES [dbo].[Productos] ([ProductoId])
ALTER TABLE [dbo].[DetallesVenta]  WITH CHECK ADD  CONSTRAINT [FK_DetallesVenta_Ventas] FOREIGN KEY([VentasId])
REFERENCES [dbo].[Ventas] ([VentasId])
ALTER TABLE [dbo].[DetallesVenta] CHECK CONSTRAINT [FK_DetallesVenta_Ventas]

-- PARA TENER NORMALIZADA AL BASE DE DATOS SE CONSIDERO CREAR LAS TABLAS CATEGORIAS, REGIONES, VENDEDORES

CREATE TABLE [dbo].[Categorias](
	[CategoriaId] [int] NOT NULL,
	[NombreCategoria] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoriaId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [dbo].[Regiones](
	[RegionId] [int] NOT NULL,
	[NombreRegion] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[RegionId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [dbo].[Vendedores](
	[VendedorId] [int] IDENTITY(1,1) NOT NULL,
	[NombreVendedor] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[VendedorId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

-- PARA REALIZAR LA CARGA DE LOS DATOS (.CSV) PROPORCIONADOS SE USO

BULK INSERT nombretabla
FROM 'C:\bkSql\Ventas.csv' -- ubicacion y nombre de archivo a acargar
WITH (
	FIELDTERMINATOR = '|', -- Delimitador de campos (barra vertical)
    ROWTERMINATOR = '\n', -- Delimitador de filas (nueva línea)
    TABLOCK
);

---PARA CARGAR LOS DATOS EN TABLA ENCABEZADO DE VENTAS (VENTAS) SE HIZO DE LA SIGUIENTE MANERA

Insert into Ventas
	select VentasId as VentasId,
		ClienteId as clienteId,
		Convert(date,fechaVenta,103) as fechaVenta,
		regionId as regionId,
		null as VendedorId
	from #Tmp_Ventas
	
---PARA CARGAR LOS DATOS EN TABLA DetallesVenta SE HIZO DE LA SIGUIENTE MANERA	

Insert into DetallesVenta (VentasId,productoId,cantidad,precioUnitario,totalVenta)
	select
		a.VentasId ,
		a.ProductoId,
		a.cantidad,
		b.preciounitario,
		a.Cantidad*b.precioUnitario as totalVenta
	from #Tmp_Ventas a inner join Productos b on b.ProductoId=a.ProductoId
