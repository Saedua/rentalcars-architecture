# rentalcars-architecture

## Diagrama de la arquitectura

![Diagrama la arquitectura](images/diagrama.png)

## Justificacion de los servicios

### Base de datos transaccional

Se eligio Azure SQL Database ya que es una base de datos relacional al estar basada en SQL Server. Compatible con herramientas conocidas como SSMS, Azure Data Studio y Visual Studio. Este servicio cifra los datos en reposo automaticamente, brinda cifrado en transito mediante TLS y nos proporciona un firewall para poder restringir el acceso a Ips especificas.
Ademas, nos permite escalar verticalmente y horizontalmente, y tiene una integracion muy buena con otros servicios de Azure.

### Almacenamiento analitico

Se eligio Azure Data Lake por su capacidad de almacenamiento escalable, su compatibilidad nativa con formatos como JSON y su integracion con el ecosistema analitico de Azure. Ademas, el Data Lake se encuentra conectado tanto con la base de datos transaccional, como con el servicio Azure IoT Hub, a traves de Azure Stream Analytics, permitiendo ingesta continua de datos de telemetria provenientes de los vehiculos.

### Orquestacion de Datos

Se eligio Azure Data Factory como el servicio mas adecuado debido a su capacidad para automatizar, programar y monitorear flujos de datos entre multiples origenes y destinos. Permite la ejecucion de flujos ETL en horarios definidos, optimizando el uso de recursos para cargas por lotes. Tiene una conectividad amplia con servicios como Azure SQL Database, Azure Data Lake y Synapse Analytics, lo que nos permite extraer informacion, transformarla y cargarla en un entorno analitico.

### Plataforma de analisis

Se selecciono Azure Synapse Analytics debido a la capacidad de integrar almacenamiento, analisis y visualizacion avanzada en un entorno unificado, optimizado para procesar volumenes masivos de datos provenientes de diferentes fuentes.
Synapse incluye un entorno de trabajo con Spark Pools con Apache Spark, lo que permite ejecutar analisis sobre grandes volumenes de datos JSON almacenados en un Data Lake sin necesidad de moverlos ni transformarlos previamente.
Ademas, permite combinar codigo en Python, SQL, Scala o .NET para notebooks colaborativos dentro de un mismo entorno.
En el caso de la arquitectura, tiene una integracion directa con Azure Data Lake, permitiendo consultas en tiempo casi real y analisis de tendencias, patrones de uso o comportamiento vehicular. Es ideal para procesar informacion en formato JSON.

### Gestion de secretos

Se eligio Azure Key Vault como servicio para gestion de secretos debido a su capacidad de almacenar, proteger y administrar de forma centralizada credenciales, claves de cifrado y certificados utilizados en la arquitectura. Permite la seguridad, trazabilidad y control de acceso de los elementos sensibles.

## Capturas de Pantalla

#### Ultimo "terraform apply" hecho de forma exitosa

![Terraform apply](images/terraformapply.png)

Se aplicaron varios terraform apply segun se iba creando el proyecto, algunos fracasaban al necesitarse mas configuraciones o por dependencias, politicas, etc. Este ultimo terraform apply corresponde a la creacion del Azure Synapse Analytics, especificamente la creacion de una politica de acceso para poder crear la conexion entre Synapse y el Data Lake

#### Grupo de recursos creado

![Resource group](images/resourcegroup.png)

El grupo de recursos final creado, conforme a la arquitectura planteada para la solucion.

## Reflexiones finales

- Uno de los problemas principales fue el de control de acceso con el Key Vault. Al configurar el Data Factory para utilizar el Key Vault, nos encontramos con el error de que tambien se debian configurar las conexiones y politicas de acceso del Data Factory al Key Vault. Y tambien varios errores de recursos que se creaban antes de algo que necesitaban, por lo que se agrego la instruccion "depends_on", para que estos se crearan luego de lo que se indicaba.

- Al trabajar en equipo se tuvo problemas con la sincronizacion del archivo terraform.tfstate, ya que tenia el error de mostrar cambios que se iban a aplicar de recursos/servicios ya creados en el grupo de recursos. Para ello se tuvo que crear un servidor llamado tfstate, definido en backend.tf. Gracias a ello y a importar manualmente algunos recursos finales, se logro obtener la sincronizacion del archivo tfstate. Se aprendio la leccion de definir este servidor y la sincronia del tfstate antes de comenzar a trabajar en equipo.

- El servicio de orquestacion de Azure resulta ser menos complejo a la hora de programar los scripts de transformacion que la forma tradicional de programarlos. Ademas que su integracion con el Key Vault y su facil conexion con la OLTP y la OLAP, resulta ser una opcion mas segura, la configuracion de seguridad queda en manos de Azure sin muchas preocupaciones y si se utilizan servicios para las bases de datos OLTP y OLAP que esten corriendo dentro de Azure, la integracion con este es muchisimo mas sencillo que con el script manual y sin ser propensos a errores. Ahorrando tiempo gracias a su eficiencia y facil integracion.

- OLTP se dirijirá principalmente a las transacciones que hacen funcionar la lógica del negocio y esta debe asegurar el cumplimiento de la ruta crítica de la aplicación para que esta finalice su cometido, evitando a toda costa interrupciones percibidas por el usuario. Por otro lado OLAP se encargará de ejecutar consultas complejas y obtener análisis de datos cuatiosos. Por lo que se observa la necesidad de sus separación, mienstras que OLTP ejecuta transacciones de forma recurrente y de menor peso, OLAP ejecuta con menor recurrencia sin embargo de peso elevado, obviando el caso de análisis en tiempo real que es aun más intensivo en recursos.
  Y es por eso que identificamos que si consultas pesadas corren en la BD transaccional de reservas esta puede afectar el rendimientos o ser una vulnerabilidad en la continuidad de servicios ejecutados para los usuarios finales.
