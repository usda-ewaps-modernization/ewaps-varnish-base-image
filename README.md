# Varnish Cache version 1.0 #

This is a containerized of the high performance web content cache 

### How do I get set up? ###

* Docker command prompt: docker-compose up -d
* Within Rancher: Create a Stack using the docker-compose.yml and rancher-compose.yml files within this Repo.

### Contribution guidelines ###

* Writing tests
* Code review

### Who do I talk to? ###

* Repo owner

### Rancher ###
#### Configuration ####
* Set up your backend application with the Rancher name 'webbackend'
** The Varnish contaienr VCL is looking for a host of this name.
* Create a varnish service using this image and add a service link to 'webbackend' with alias 'webbackend'
* Varnish is listening on the default 6081 port.

#### Environment Variables (optional) ####
These can be modified by editing the Environment Variable in Rancher under the Command tab for the Varnish service.  

* Memory  
_VARNISH_MENORY = 512M_   
Default Value:   
  _VARNISH_MEMORY = 256M_    
    
* Varnish Logging   
Comprehensive Logging to File:     
  _VARNISHLOG_ARGS: -a -w /var/log/varnish/varnish.log_   
Error Only Logging to File:   
  _VARNISHLOG_ARGS: -a -w /var/log/varnish/varnish.log -q "RespStatus >= 400 or BerespStatus >= 400"_  
Default Value:    
  _VARNISHLOG_ARGS: -q "RespStatus >= 400 or BerespStatus >= 400"_   
