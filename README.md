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
      kubectl apply -f postgresql.yaml
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
