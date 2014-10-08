module: deft-deploy
author: Fabrice Leal
copyright: See LICENSE file in this distribution.


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
  help "Create a simple Procfile for the current project.";
  implementation
    begin
      let p = dylan-project($deft-context, #f);
      if (p)	
	let exe-name = project-executable-name(p);
	let procfile :: <template>
	  = make(<template>,
		 output-path: "Procfile",
		 constant-string: $heroku-file-template,
		 arguments: list(exe-name));
	
	write-templates(procfile);
      end if
    end;
end;

define command deploy docker ($deft-commands)
  help "Create a simple Dockerfile for the current project";
  simple parameter version :: <string>,
    help: "For now either 2013.2 or latest";
  implementation
    begin
      let p = dylan-project($deft-context, #f);
      if (p)
	let exe-name = project-build-filename(p);
	let procfile :: <template>
	  = make(<template>,
		 output-path: "Dockerfile",
		 constant-string: $docker-file-template,
		 arguments: list(version, exe-name));
	
	write-templates(procfile);
      else
	format-out("There's no selected project\n");
      end if
    end;
end;
