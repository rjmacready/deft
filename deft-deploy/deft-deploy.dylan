Module: deft-deploy
Synopsis: A command to create configuration files for third party services
Copyright: Original Code is Copyright (c) 2012 Dylan Hackers. All rights reserved. 
License: See License.txt in this distribution for details. 
Warranty: Distributed WITHOUT WARRANTY OF ANY KIND


define command check heroku ($deft-commands)
  help "Check if a project can be deployed to heroku";
  simple parameter  project-name :: <string>,
    help: "Project ...",
    required?: #t;
  implementation
    begin
      // TODO check if it's executable
      // TODO other checks?
    end;
end;

define command deploy heroku ($deft-commands)
  help "Create a Procfile (heroku) for a project.";
  simple parameter project-name :: <string>,
    help: "Project ...",
    required?: #t;
  implementation
    begin
      // generate-project(project-name, type: #"dll");
      let config = deft-config();
      let app-name = element(config, "name", default: #f);

      let procfile :: <template>
	= make(<template>,
	       output-path: "Procfile",
	       constant-string: $heroku-file-template,
	       arguments: list(app-name));

      write-templates(procfile);

    end;
end;

define command deploy docker ($deft-commands)
  help "Create a Dockerfile for a project";
  simple parameter project-name :: <string>,
    help: "Project ...",
    required?: #t;
  implementation
    begin
      format-out("TODO\n");
    end;
end;
