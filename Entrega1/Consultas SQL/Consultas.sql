-- CONSULTAS DE VALIDACION 
-- VENTAS TOTALES POR CATEGORIA DE PRODUCTO
SELECT B.categoriaid as Categoria_Producto    
	,SUM(A.cantidad*B.preciounitario) as Ventas 
FROM dbo.detallesventa A  
LEFT JOIN dbo.productos B ON (A.productoid = B.productoid) 
LEFT JOIN dbo.ventas  C ON (A.ventasid = C.ventasid) 
GROUP BY B.categoriaid ORDER BY B.categoriaid DESC

-- CLIENTES CON MAYOR VALOR DE COMPRA
SELECT C.clienteid
	  ,C.nombrecliente
	  ,SUM(A.cantidad*A.preciounitario) as Ventas
FROM dbo.detallesventa A 
LEFT JOIN dbo.ventas   B ON (A.ventasid = B.ventasid)
LEFT JOIN dbo.clientes C ON (B.clienteid = c.clienteid)
GROUP BY C.clienteid
		,C.nombrecliente
ORDER BY SUM(A.cantidad*A.preciounitario) DESC

-- PRODUCTOS MAS VENDIDOS POR REGION   
SELECT D.nombreregion as Region
	  ,B.nombreproducto as Producto
	  ,SUM(A.cantidad) as Cantidad_Vendida
FROM dbo.detallesventa A 
LEFT JOIN dbo.productos	B ON (A.productoid = B.productoid)
LEFT JOIN dbo.ventas	C ON (A.ventasid = C.ventasid)
LEFT JOIN dbo.regiones	D ON (C.regionid = D.regionid)
GROUP BY D.nombreregion
		,B.nombreproducto
ORDER BY D.nombreregion
		,SUM(A.cantidad) DESC
