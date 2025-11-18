# baculum-kubernetes
Instalacion de bacula con baculum en kubernetes

> [\!TIP]
> Si no tienes un clúster de Kubernetes, puedes seguir mi [guía de instalación](https://github.com/1237446/Instalacion-de-RK2-con-Cilium).

-----

## 1\. Despliegue de Postgresql

Utilizaremos el operador de CloudNativePG (CNPG) para gestionar nuestro clúster de base de datos de forma automatizada.

  * **Crea el namespace para Bacula:**
  
      ```bash
      kubectl create namespace bacula
      ```

  * **Instala el operador:**
  
      ```bash
      kubectl apply --server-side -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.1.yaml
      ```

  * **Creamos los configmaps:**

      ```bash
      kubectl create configmap bacula-schema-grants --from-file=grants.sql=./postgresql/grant_postgresql_privileges.sql --namespace bacula

      kubectl create configmap bacula-schema-tables --from-file=tables.sql=./postgresql/make_postgresql_tables.sql --namespace bacula
      ```

  * **Despliega el clúster de Postgresql:**
  
      ```bash
      kubectl apply -f postgresql.yaml -f postgresql-secrets.yaml
      ```
  
  * **Verifica que los Pods del clúster estén listos:**
  
      ```bash
      kubectl get pods -n bacula
      
      NAME                 READY   STATUS    RESTARTS   AGE
      postgresql-node-0    1/1     Running   0          4m
      postgresql-node-1    1/1     Running   0          4m
      postgresql-node-2    1/1     Running   0          4m
      ```

-----

## 2\. Despliegue de Bacula

Ahora, despliega los componentes principales de Bacula (Director, Storage Daemon y File Daemon).

  * **Aplica los manifiestos de Bacula:**
  
      ```bash
      kubectl apply -f bacula/
      ```
  
  * **Verifica que los pods de Bacula estén en ejecución:**
  
      ```bash
      kubectl get pods -n bacula
      
      NAME                           READY   STATUS    RESTARTS   AGE
      bacula-dir-bdc694575-8g5tq     1/1     Running   0          3m
      bacula-fd-785ddf8674-kffsz     1/1     Running   0          3m
      bacula-sd-76986d9f78-tpzz8     1/1     Running   0          3m
      ```

-----

## 3\. Despliegue de Baculum (GUI)

Finalmente, despliega la interfaz web de Baculum, que consiste en una API y el frontend web.

  * **Aplica los manifiestos de Baculum:**
  
      ```bash
      kubectl apply -f baculum/
      ```
  
  * **Verifica que los pods de Baculum estén listos:**
  
      ```bash
      kubectl get pods -n bacula
      
      NAME                           READY   STATUS    RESTARTS   AGE
      baculum-api-5cb974c57-42sqm    1/1     Running   0          5m
      baculum-web-75f6cccbcb-5pw9t   1/1     Running   0          5m
      ```

-----

## 4\. Guía de Instalación del Agente Bacula (Windows File Daemon)

Esta guía detalla el proceso para descargar, instalar y configurar el agente de cliente de Bacula en un entorno Windows.

   ### Descarga del Software
   
   * **Acceda al sitio web oficial:** Diríjase al [Centro de Descargas de Bacula](https://www.bacula.org/binary-download-center/).
     
   *  **Seleccione el instalador:** Localice y descargue los binarios para Windows correspondientes a la versión **15.0.3** (asegúrese de elegir la arquitectura correcta, usualmente 64-bits).
   
   ![guia](pictures/agent-windows-0.png)
   
   ### Proceso de Instalación
   
   *  **Ejecutar el instalador:** Abra el archivo descargado en el equipo cliente Windows.

   ![guia](/pictures/agent-windows-1.jpeg)
     
   *  **Acuerdo de Licencia:** Lea y acepte los términos de la licencia para continuar.

   ![guia](/pictures/agent-windows-2.jpeg)
     
   *  **Tipo de Instalación:** Cuando se le solicite, seleccione el tipo de instalación **Custom** (Personalizada).

   ![guia](/pictures/agent-windows-3.jpeg)
     
   *  **Selección de Componentes:**
     
       * Despliegue la lista de componentes.
       
       ![guia](/pictures/agent-windows-4.jpeg)
       
       * Asegúrese de marcar **Client -> File Service**.
    
   > [\!NOTE]
   >  Esto instalará únicamente el servicio necesario para que el servidor Bacula pueda realizar copias de seguridad de este equipo.
         
   *  **Directorio de Instalación:** Seleccione la ruta donde se alojarán los archivos de Bacula o mantenga la ruta por defecto.

       ![guia](/pictures/agent-windows-5.jpeg)
    
   *  **Configuración del Cliente (File Daemon):**

       * **Nombre del Agente:** Ingrese un nombre único para identificar a este cliente en la red.
       * **Contraseña:** Defina una contraseña segura.

       ![guia](/pictures/agent-windows-6.jpeg)

   > [!WARNING]
   > Guarde el **Nombre del Agente** y la **Contraseña** en un lugar seguro. Estos datos son obligatorios para configurar posteriormente el archivo `bacula-dir.conf` en el servidor Director.
     
   *  **Configuración del Director y Monitor:**
     
       * **Nombre del Director:** Ingrese el nombre exacto del Director de Bacula que gestionará este cliente.
     
       * **Monitor:** Si va a utilizar un monitor de estado, defina su nombre y contraseña.
    
       ![guia](/pictures/agent-windows-7.jpeg)
      
   > [\!NOTE]
   >  Al igual que en el paso anterior, registre estas credenciales, ya que deben coincidir exactamente con la configuración del servidor.
       
   *  **Finalización:** Haga clic en **Instalar**, espere a que la barra de progreso se complete y seleccione **Finalizar**.

       ![guia](/pictures/agent-windows-8.jpeg)

       ![guia](/pictures/agent-windows-9.jpeg)
   
   ### Configuración del Firewall de Windows (Entrada y Salida)

   Para garantizar la comunicación bidireccional correcta con el servidor, configuraremos reglas tanto para el tráfico entrante como saliente.

   > [\!TIP]
   > Otra alternativa para activar el firewall es usando el script ![**bacula.bat**](bacula.bat)
   
   *  **Abrir configuración:** Busque y abra "Windows Defender Firewall con seguridad avanzada".
     
   *  **Crear Regla de Entrada:**
     
       * En el panel izquierdo, seleccione **Reglas de entrada** (*Inbound Rules*).
     
       * En el panel derecho, haga clic en **Nueva regla...**
        
   *  **Tipo de Regla:** Seleccione la opción **Puerto**.

       ![guia](/pictures/agent-windows-10.jpeg)
     
   *  **Protocolo y Puertos:**
     
       * Seleccione **TCP**.
        
       * En "Puertos locales específicos", ingrese el puerto estándar del agente: **9101-9103**.
    
         ![guia](/pictures/agent-windows-11.jpeg)
        
   *  **Acción:** Seleccione **Permitir la conexión**.

         ![guia](/pictures/agent-windows-12.jpeg)
     
   *  **Perfil:** Marque todas las casillas que apliquen a su entorno (Dominio, Privado y Público) para asegurar la conectividad.

         ![guia](/pictures/agent-windows-13.jpeg)
     
   *  **Nombre:** Asigne un nombre descriptivo a la regla, por ejemplo: `Bacula`.

         ![guia](/pictures/agent-windows-14.jpeg)
     
   *  **Guardar:** Haga clic en Finalizar para activar la regla.

   ### Verificación del Servicio
   
   Antes de dar por finalizada la instalación en el cliente, debemos confirmar que el agente se está ejecutando correctamente.

   * Presione las teclas Windows + R, escriba services.msc y presione Enter.    
   * En la lista de servicios, busque el llamado Bacula File Daemon.  
   * Verifique la columna "Estado": debe decir En ejecución (Running).   
   * Verifique la columna "Tipo de inicio": debe estar en Automático.  
      * Si el servicio no está corriendo: Haga clic derecho sobre él y seleccione Iniciar.
     
