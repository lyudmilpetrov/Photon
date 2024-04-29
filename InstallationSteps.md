1) Install Node
https://nodejs.org/en
2) Install Maven
    https://maven.apache.org/
    Add the path to system enviroment variable `C:\Program Files\apache-maven-3.9.6\bin`
3) Install JDK
    https://www.oracle.com/java/technologies/downloads/#jdk21-windows
    Add the path to system enviroment variable `C:\Program Files\Java\jdk-17\bin`
4) Get Photon
    `git clone https://github.com/komoot/photon.git`
5) Get database https://www.graphhopper.com/
    `wget -O - https://download1.graphhopper.com/public/photon-db-latest.tar.bz2 | bzip2 -cd | tar x`
    # you can significantly speed up extracting using pbzip2 (recommended):
    `wget -O - https://download1.graphhopper.com/public/photon-db-latest.tar.bz2 | pbzip2 -cd | tar x`
6) Save the unzipped photon_data folder in the `~/photon/target` folder
7) cd into `~/photon` folder and run cmd command `mvn package -DskipTests`
8) cd into `~/photon/target` and run cmd command `java -jar photon-0.4.4.jar`
9) Create the stored procedure within targeted sql database see file: `StoredProcedure.sql`
10) Use Powershell Script to call the web server of photon see file: `GetCoordinatesLocal.ps1`