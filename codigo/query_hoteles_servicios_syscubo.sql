
DECLARE @hot_serv TABLE (
	Clav_Hotel INT
	, Clav_Servicio VARCHAR(20)
)

DECLARE @listaHoteles AS TABLE (
	Clav_Hotel INT
)

-- Lista de hoteles que queremos (por geograf�a, etc)
INSERT INTO @listaHoteles
EXEC spRM_ObtenerListaDeHoteles

-- Generamos los servicios de plan de alimentos y los insertamos en @hot_serv
INSERT INTO @hot_serv
SELECT
	Clav_Hotel
	, Clav_Servicio
FROM (
	SELECT
		hct.Clav_Hotel
		, p.Clav_Agrupador
		, ra.Rango_Agrupador
		, ROW_NUMBER() 
				over (Partition BY hct.Clav_Hotel
					ORDER BY ra.Rango_Agrupador DESC )
			rango
	FROM (SELECT distinct Clav_Hotel, Clav_Plan FROM dbo.hoteles_cuartos_Tarifas2 with (nolock)) hct 
		INNER JOIN dbo.Planes p with (nolock)
			ON hct.Clav_Plan = p.Clav_Plan
		LEFT JOIN dbo.RM_Rangos_Agrupadores ra
			ON p.Clav_Agrupador = ra.Clav_Agrupador
	GROUP BY hct.Clav_Hotel
		, p.Clav_Agrupador
		, ra.Rango_Agrupador
	) t1
	INNER JOIN dbo.RM_Agrupadores_Servicios ac
		ON t1.Clav_Agrupador = ac.Clav_Agrupador
WHERE t1.rango = 1
ORDER BY t1.Clav_Hotel

-- Insertamos los dem�s servicios (provenientes de Hoteles_Servicios) en @hot_serv
INSERT INTO @hot_serv
SELECT
	hs.Clav_Hotel,
	hs.Clav_Servicio
FROM dbo.Hoteles_Servicios hs WITH (NOLOCK)
-- Agregar esto cuando est� la tabla de servicios en cubo
/*	INNER JOIN dbo.Servicios s WITH (NOLOCK)
		ON hs.Clav_Servicio = s.Clav_Servicio
WHERE s.esCasa = 1
--ORDER BY s.Orden
*/

-- Regresamos el resultado
SELECT
	hs.Clav_Hotel
	, tcs.Codigo AS Categoria
	, count(tcs.Codigo) as Cantidad
FROM @hot_serv hs
	INNER JOIN @listaHoteles lh					-- S�lo de los hoteles obtenidos en la lista
		ON hs.Clav_Hotel = lh.Clav_Hotel
	INNER JOIN Clasificaciones_Servicios cs
		ON hs.Clav_Servicio = cs.Clav_Servicio
	INNER JOIN Tipos_Clasificaciones_Servicios tcs
		ON cs.Clav_TipoClasificacionServicio = tcs.Clav_TipoClasificacionServicio
WHERE tcs.Codigo <> 'ZIGNORE'					-- Categoria a ignorar
GROUP BY hs.Clav_Hotel, tcs.Codigo
ORDER BY hs.Clav_Hotel, tcs.Codigo






