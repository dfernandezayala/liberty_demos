#!/bin/bash
clusterdns="ibkclusterdev"
ipaddressv4="169.62.202.162"
icp_version=2
liberty_demo_path="/Users/dfernandez/ICp"

# Agregar la entrada en /etc/hosts si no existiere
#sudo echo "$ipaddressv4  master  $clusterdns" >> /etc/hosts

# Crear directorio de Demos
cd $liberty_demo_path
#mkdir liberty_demo

# Clonar el ejemplo desde Git
#git clone https://github.com/openliberty/guide-docker.git
#cd guide-docker/

# Si es MAC instalar MVN
#brew update
#brew install mvnvm

# Si es Linux instalar MVN
#yum install -y mvn

# Compilar el proyecto
#cd guide-docker/start
#mvn clean install
#cd $liberty_demo_path/guide-docker

# Ejecutar el contenedor
#docker run -d --name rest-app -p 9080:9080 -p 9443:9443 -v $liberty_demo_path/liberty_demo/guide-docker/start/target/liberty/wlp/usr/servers:/servers liberty-demo

# Si es necesario verificar o ejecutar una tarea dentro del contenedor
#docker exec -ti rest-app /bin/bash # Ejecutar el comando "exit" una vez que se culmina las tareas
#docker commit rest-app # Ejecutar este comando en otro terminal si se desea conservar los cambios realizados en el contenedor


# Crear proyecto con Kubernetes e IBM Cloud Private
cd $liberty_demo_path/liberty_demo
git clone https://github.com/OpenLiberty/guide-kubernetes-intro

# Compilar el proyecto
cd guide-kubernetes-intro/start/
mvn package
cd $liberty_demo_path/liberty_demo

# Etiquetar las imágenes
docker tag ping:1.0-SNAPSHOT $clusterdns:8500/default/ping:1.0-SNAPSHOT
docker tag name:1.0-SNAPSHOT $clusterdns:8500/default/name:1.0-SNAPSHOT

# Subir las imágenes al repositorio de ICP
docker login $clusterdns.icp:8500 --username admin --password admin 
docker push $clusterdns.icp:8500/default/ping:1.0-SNAPSHOT
docker push $clusterdns.icp:8500/default/name:1.0-SNAPSHOT

# Si la versión es 2.3.0.1 usar bx, si es 3.1 usar cloudctl
if [ "$icp_version" = "2" ]
then
    bx pr login -a https://$clusterdns.icp:8443 --skip-ssl-validation -u admin -p admin -c id-$clusterdns-account
else 
    cloudctl login -a https://$clusterdns.icp:8443 --skip-ssl-validation -u admin -p admin -c id-$clusterdns-account
fi

# Crear el despliegue de la aplicacion de Demo
if [ "$clusterdns" = "mycluster" ]
then
    kubectl create -f k8s.yaml
else
    find_and_match="s/mycluster/$clusterdns/g"
    sed $find_and_match k8s.yaml > k8s_.yaml
    kubectl create -f k8s_.yaml
fi
