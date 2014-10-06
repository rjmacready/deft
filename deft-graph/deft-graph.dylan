module: deft-graph

define thread variable *root-project* :: false-or(<project-object>) = #f;
define thread variable *parent-object* :: false-or(<environment-object>) = #f;
define thread variable *parent-node* :: false-or(<node>) = #f;
define thread variable *node-dictionary* :: false-or(<table>) = #f;
define thread variable *graph* :: false-or(<graph>) = #f;

define class <edge-type> (<object>)
end class;

define class <root> (<edge-type>)
end class;

define class <has> (<edge-type>)
end class;

define class <sees> (<edge-type>)
end class;

define class <defines> (<edge-type>)
end class;

define class <uses> (<edge-type>)
end class;

define method print-object (o :: <has>, stream :: <stream>) => ()
  format(stream, "%s", "has");
end method;

define method print-object (o :: <sees>, stream :: <stream>) => ()
  format(stream, "%s", "sees");
end method;

define method print-object (o :: <defines>, stream :: <stream>) => ()
  format(stream, "%s", "defines");
end method;

define method print-object (o :: <uses>, stream :: <stream>) => ()
  format(stream, "%s", "uses");
end method;

define constant $root = make(<root>);
define constant $has = make(<has>);
define constant $sees = make(<sees>);
define constant $defines = make(<defines>);
define constant $uses = make(<uses>);

// from code-browser
define function dylan-name(definition :: <environment-object>) => (name :: <string>)
  let name = environment-object-home-name(*root-project*, definition);
  if (name)
    environment-object-primitive-name(*root-project*, name)
  else
    environment-object-display-name(*root-project*, definition, #f, qualify-names?: #f)
  end
end function;

define function create-node!(node-label)
  let node = element(*node-dictionary*, node-label, default: #f);
  if (~node)
    node := create-node(*graph*, label: node-label);
    *node-dictionary*[node-label] := node;
  end if;
  node
end function;


define generic walk (object :: <environment-object>, edge :: <edge-type>) => ();

define method walk (project :: <project-object>, edge :: <edge-type>) => ()
  open-project-compiler-database(project);
  parse-project-source(project);
  
  let node = create-node!(project-name(project));
  
  let library = project-library(project);
  if (library)
    dynamic-bind(*parent-object* = project, *parent-node* = node)
      walk(library, $has);
    end;
  end if;
end method;

define method walk (library :: <library-object>, edge :: <edge-type>) => ()
  let node-label = format-to-string("L:%s", dylan-name(library));
  let node = create-node!(node-label);
  
  create-edge(*graph*, *parent-node*, node, label: format-to-string("%=", edge));
  
  dynamic-bind(*parent-object* = library, *parent-node* = node)
    do-library-modules((method(module)
			  walk(module, $sees)
			end), *root-project*, library);
  
    do-library-modules((method(module)
			  walk(module, $defines)
			end), *root-project*, library, imported?: #f);

  end;
end method;

define function walk-module (module :: <module-object>, edge :: <edge-type>)
  let node-label = format-to-string("M:%s", dylan-name(module));
  let node = create-node!(node-label);
    
  create-edge(*graph*, *parent-node*, node, label: format-to-string("%=", edge));
  
  dynamic-bind(*parent-object* = module, *parent-node* = node)
    do-used-definitions(method(def)
			  walk(def, $uses);
			end, *root-project*, module);
  
    do-module-definitions(method(def)
			    walk(def, $defines);
			  end, *root-project*, module);
  end;
end function;

define method walk (module :: <module-object>, edge :: <sees>) => ()
   // don't follow a module that we see
end method;

define method walk (module :: <module-object>, edge :: <uses>) => ()
  walk-module(module, edge);
end method;

define method walk (module :: <module-object>, edge :: <defines>) => ()
  walk-module(module, edge);
end method;

define function make-node(prefix :: <string>, object :: <environment-object>, edge :: <edge-type>) => ()
  let node-label = format-to-string("%s:%s", prefix, dylan-name(object));
  let node = create-node!(node-label);
  
  create-edge(*graph*, *parent-node*, node, label: format-to-string("%=", edge));  
end function;

// <class-object>, <method-object>, <constant-object>, ...
define method walk (object :: <environment-object>, edge :: <defines>) => ()
  // make-node("", object, edge);
end method;


define function deft-graph-project(name :: false-or(<string>)) => ()
  let project = dylan-project($deft-context, name);
  if (project)
      dynamic-bind(*root-project* = project, 
		   *node-dictionary* = make(<case-insensitive-string-table>),
		   *graph* = make(<graph>))
        walk(project, $root);
    
        let file-name = format-to-string("%s-graph", project-name(project));
    
        with-open-file (file = concatenate(file-name, ".dot"), direction: #"output", if-exists: #"overwrite")
          generate-dot(*graph*, file);
	end;
        format-out("wrote dot: %s.dot\n", file-name);
        with-open-file (file = concatenate(file-name, ".gml"), direction: #"output", if-exists: #"overwrite")
          generate-gml(*graph*, file);
        end;
      end;
  else
      format-out("open a project first\n");
  end if;
end function;


define command graph ($deft-commands)
  help "Exports a graph with the dependencies between objects.";
  simple parameter project :: <string>,
    help: "The project to clean. If not specified, defaults to the current project.",
    node-class: <open-dylan-project-parameter>;
  implementation
    deft-graph-project(project);
end;
