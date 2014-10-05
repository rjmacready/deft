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

define method walk (module :: <module-object>, edge :: <sees>) => ()
   // don't follow a module that we see
end method;

define method walk (module :: <module-object>, edge :: <uses>) => ()
  // don't follow a module that we use
end method;

define method walk (module :: <module-object>, edge :: <defines>) => ()
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
end method;

define function make-leaf(prefix :: <string>, object :: <environment-object>, edge :: <edge-type>) => ()
  let node-label = format-to-string("%s:%s", prefix, dylan-name(object));
  let node = create-node!(node-label);
  
  create-edge(*graph*, *parent-node*, node, label: format-to-string("%=", edge));  
end function;

define method walk (object :: <environment-object>, edge :: <defines>) => ()
  make-leaf("", object, edge);
  // nothing
end method;

/*
define method walk (class-object :: <class-object>, edge :: <defines>) => ()
  make-leaf("Class", class-object, edge);
end method;

define method walk (method-object :: <method-object>, edge :: <defines>) => ()
  make-leaf("Method", method-object, edge);
end method;

define method walk (const-object :: <constant-object>, edge :: <defines>) => ()
  make-leaf("Constant", const-object, edge);
end method;

define method walk (const-object :: <domain-object>, edge :: <defines>) => ()
  make-leaf("Domain", const-object, edge);
end method;

define method walk (const-object :: <generic-function-object>, edge :: <defines>) => ()
  make-leaf("Generic function", const-object, edge);
end method;

define method walk (object :: <macro-object>, edge :: <defines>) => ()
  make-leaf("Macro", object, edge);
end method;
*/

define function export-to-graph()
  let project = dylan-current-project($deft-context);
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
/*
define function export-to-graph-old()
  let modules-node-table = make(<case-insensitive-string-table>);

  let project = dylan-current-project($deft-context);
  if (project)

    open-project-compiler-database(project);
    parse-project-source(project);
  
    let graph = make(<graph>);
    let project-node = create-node(graph, 
				   label: format-to-string("P:%s", project-name(project)));
    
    //let project-used-libraries = project-used-libraries(project, project);
    //for (library in project-used-libraries)
    //  format-out("library used %= (%=)\n", library, dylan-name(project, library));
    //end for;
    
    let library = project-library(project);
    if (library)
      format-out("library %= (%=)\n", library, dylan-name(project, library));
      
      let library-node = create-node(graph, 
				     label: format-to-string("L:%s",
							     dylan-name(project, library)));
      library-node.attributes["shape"] := "box";
      library-node.attributes["style"] := "filled";
      library-node.attributes["color"] := ".7 .3 1.0";
      
      create-edge(graph, project-node, library-node, label: "has library");

      do-library-modules((method(module)
			    let module-name = dylan-name(project, module);
			    format-out("visible module %= (%=)\n", module, module-name);
			    
			    module-name := format-to-string("M:%s", module-name);
			    
			    let module-node = element(modules-node-table, module-name, default: #f);
			    if (~module-node)
			      module-node := create-node(graph, label: module-name);
			      modules-node-table[module-name] := module-node;
			    end if;
			    
			    create-edge(graph, library-node, module-node, label:"can see");
			    
			 end), project, library);
      
      do-library-modules((method(module)

			    let module-name = dylan-name(project, module);
			    
			    format-out("defined module %= (%=) at %=\n", module, 
				       module-name,
				       environment-object-source-location(project, module));
		
			    
			    //let defined-module-node = create-node(graph,
			    //					  label: format-to-string("M:%s", dylan-name(project, module)));
			    //create-edge(graph, library-node, defined-module-node, label: "defines module");
			    
			    module-name := format-to-string("M:%s", module-name);
			    
			    let defined-module-node = element(modules-node-table, module-name, default: #f);
			    if (~defined-module-node)
			      defined-module-node := create-node(graph, label: module-name);
			      modules-node-table[module-name] := defined-module-node;
			    end if;
			    
			    create-edge(graph, library-node, defined-module-node, label:"defines module");
			    
			    
			    do-used-definitions((method(def)
						   let def-name = dylan-name(project, def);
						   
						   format-out(" a used module %= (%=) at %=\n", def,
							      def-name,
							      environment-object-source-location(project, def));
						   
						   def-name := format-to-string("M:%s", def-name);
			    
						   let used-module-node = element(modules-node-table, def-name, default: #f);
						   if (~used-module-node)
						     used-module-node := create-node(graph, label: def-name);
						     modules-node-table[def-name] := used-module-node;
						   end if;
						   
						   create-edge(graph, defined-module-node, used-module-node, label:"uses module");
						   
						end), project, module);

			    do-module-definitions((method(def)
						     let defined-name = dylan-name(project, def);
						     
						     format-out(" a definition %= (%=) at %=\n", def,
								defined-name,
								environment-object-source-location(project, def));
						     
						     let definition-node = create-node(graph,
										       label: format-to-string("D:%s", defined-name));
						     create-edge(graph, defined-module-node, definition-node, label: "defines");
						     
						     format-out("\n");
						     format-out("%=", 
								environment-object-source(project, def));
						     format-out("\n");

						     // TODO check argument's types
						     // TODO check return type
						     // TODO try to get definition body

						     do-used-definitions((method(another)
									    format-out("   something %= (%=)\n", another, dylan-name(project, another));
									  end),
									 project, def);
						   end), project, module);
			    
			 end), project, library, imported?: #f);

      do-used-definitions((method(module)
			    format-out("used definition %= (%=)\n", module, dylan-name(project, module));
			 end), project, library);

      /*
      let modules = library-modules(project, library);
      for(module in modules)
	format-out("module %= (%=)\n", module, dylan-name(project, module));
	do-module-definitions((method (def)
				 format-out(" def %= (%=)\n", def, dylan-name(project, def));
			       end) ,project, module)
      end for;
      */
      /*
	let object = find-environment-object(project, name,
	library: library,
	module: first(library-modules(project, library)) );
	print-environment-object(project, object); 
	*/

      
      
      let file-name = "test";
      with-open-file (file = concatenate(file-name, ".dot"), direction: #"output", if-exists: #"overwrite")
	generate-dot(graph, file);
      end;
      format-out("wrote dot: %s.dot\n", file-name);
      with-open-file (file = concatenate(file-name, ".gml"), direction: #"output", if-exists: #"overwrite")
	generate-gml(graph, file);
      end;

      format-out("wrote gml: %s.gml\n", file-name);
      
    else
      format-out("no library?");
    end if
  else
    format-out("no project?");
  end if
end function;
*/

define command graph ($deft-commands)
  help "Exports a graph.";
//  simple parameter dylan-project-name :: <string>,
//   help: "the dylan project",
//    required?: #t;
  implementation
    export-to-graph();
end;
