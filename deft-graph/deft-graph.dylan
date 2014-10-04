module: deft-graph



define command graph ($deft-commands)
  help "Exports a graph.";
  simple parameter dylan-project-name :: <string>,
    help: "the dylan project",
    required?: #t;
  implementation
    format-out("hello graph\n");
end;
