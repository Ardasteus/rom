# Ruby on Mails

## Summary
Mail client developed in Ruby, making minimal use of libraries on our backend.
It currently supports authentication via LDAP, sending emails via SMTP and fetching emails from server using IMAP.
Both IMAP and SMTP were implemented by hand, without using any libraries.
For databases we use either SQLite3 or MySQL, depends if you want a DB locally or not.
Front-end is made in React.

## Installation
* Install Ruby (Windows - 2.5+, Linux/UNIX - any)
* Clone the project
* Checkout to the develop branch
* Done

## Configuring the application
It is necessary to create a config.yml file in the data folder.
Each of our services is configured using the provided values in this config file

### HTTP Configuration
#### Single HTTP Server
```yaml
http:
  binding:
    - address: 127.0.0.1
      port: 8080 
```
In this example we create one HTTP server that runs on port 8080, if the port is no specified it is automatically 80.

#### Singe HTTPS Server
```yaml
http:
  binding:
    - address: 127.0.0.1
      port: 443
      https: true
      cert_path: C:\Certs\https.cert
      key_path: C:\Keys\https.key
```
In this example we create one HTTPS server that uses the specified certificate and key.
If the certificate is not specified a self-signed certificate is automatically created.

#### HTTP Redirect
```yaml
http:
  binding:
    - address: 127.0.0.1
      port: 8081 
      redirect: 127.0.01:8080
```
In this example we create one HTTP server that redirects all its calls onto the provided address.

#### Multiple servers at once
```yaml
http:
  binding:
    - address: 127.0.0.1
    
    - address: 127.0.0.1
      port: 443
      https: true
```
It is also possible to create multiple servers. In this example we create 2 basic servers, one HTTP and one HTTPS.

#### HSTS
```yaml
http:
  binding:
    - address: 127.0.0.1
      redirect: 127.0.01:443

    - address: 127.0.0.1
      port: 443
      https: true
```
Using two bindings and a redirect we can achieve enforcement of HTTPS (aka. HSTS).

### DB Configuration
#### Sqlite3 DB Configuration
```yaml
db:
  databases:
    romdb:
      driver: sqlite
      connection:
        file: romdb.sqlite.db
```
In this example we tell the application to use an sqlite database and provide it with a file.

#### MySQL DB Configuration
```yaml
db:
  databases:
    romdb:
      driver: mysql
      connection:
        host: db.company.com
        user: rom-app
        database: romdb
```
Note that the only mandatory connection properties are `host` and `user`. The rest have default values (`port = 3306`, `password = null`, `database = 'romdb'`, `charset = 'utf8'`, `collation = 'utf8_general_ci'`, `engine = 'InnoDB'`).
### Authentication Configuration
#### Token Configuration
```yaml
authentication:
  tokens:
    factory: jwt
```
The first step when configuring the authentication service is to specify the type of token which will be use.
At the moment we only support jWT tokens, thus this part will always be the same.
#### Authentication Layers - Onion
The next step is to define the authentication layers of the app. That means to basically tell the application which authentication providers to use.

##### Database Authentication
```yaml
authentication:
  tokens:
    factory: jwt
  onion:
    romdb:
      driver: local
      config:
        cost: 12
```
The first option is to use a database engine to authenticate the users from. In this case we just specify which database to use.

##### Local List Authentication
```yaml
authentication:
  tokens:
    factory: jwt
  onion:
locals:
      driver: list
      config:
        users:
          - login: jgeneric
            password: Aa0123456
            first_name: Joe
            last_name: Generic

          - login: hpathetic
            password: Aa0123456
            first_name: Hoe
            last_name: Pathetic
```
 The second option is a local list of users. You need to manually specify the users and their passwords.
 Not recommended for real use.
 
 ##### LDAP Authentication
 ```yaml
 locals:
      driver: ldap
      config:
        host: ldap.company.com
        port: 389
```
The third and last option is LDAP authentication. This requires for example Active Directory to be present, form which we then authenticate the users.
The port property in this case does not need to be specified as the port defaults to 389.

## Running the application

### Using terminal
To run the application via terminal you have to:
* Go to the folder where you cloned ROM
* Run `bundle install` *(only required the first time around)*
  * Try running `gem update` and `gem install bundler` and repeat the previous step. *(if you encounter issues)*
* Create a data directory
* Create a config file `config.yml` in the data directory
* Run ROM script `bin/run.rb` in your data directory using `ruby`

### Using rake
It is also possible to start the application using `rake`. Simply running `rake run` will use folder `data` within the project as data root. Please make sure to exclude your data folder in `.git/info/exclude`. 