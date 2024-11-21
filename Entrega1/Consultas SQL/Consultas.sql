--VENTAS TOTALES POR CATEGORIA DE PRODUCTO
SELECT a.CategoriaId,c.NombreCategoria,SUM(b.totalVenta) AS Tot_Ventas_Categoria
FROM Productos a 
INNER JOIN DetallesVenta b ON a.ProductoId=b.productoId
INNER JOIN Categorias c on a.CategoriaId=c.CategoriaId
GROUP BY a.CategoriaId,c.NombreCategoria
ORDER BY Tot_Ventas_Categoria desc

--CLIENTES CON MAYOR VALOR DE COMPRA
SELECT a.ClienteId,c.NombreCliente,SUM(v.totalVenta) as Total_Compra
FROM  Ventas a INNER JOIN Clientes c ON a.clienteId=c.ClienteId
	  INNER JOIN DetallesVenta v ON a.VentasId=v.VentasId
GROUP BY a.clienteId, c.NombreCliente
ORDER BY sum(v.totalVenta) DESC	 


--PRODUCTOS MAS VENDIDOS POR REGION
SELECT r.NombreRegion,p.NombreProducto, sum(dv.cantidad) AS Total_Ventas
FROM   Regiones r INNER JOIN Ventas v ON r.RegionId = v.regionId 
INNER JOIN DetallesVenta dv ON v.VentasId = dv.VentasId
INNER JOIN Productos p ON dv.productoId = p.ProductoId  
GROUP BY r.NombreRegion,p.NombreProducto
ORDER BY sum(dv.cantidad) DESC
