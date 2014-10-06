Module: deft-deploy

//define constant $heroku-fname-template :: <string> = "Procfile"
define constant $heroku-file-template :: <string> = 
  ("web: sh start-process.sh bin/%s\n");

define constant $docker-file-template :: <string> =
  ("FROM rjmacready/opendylan:%s-onbuild\n"
   "\n"
   "CMD [\"%s\"]");
