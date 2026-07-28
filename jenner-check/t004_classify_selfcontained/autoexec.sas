/* cap input rows for the captured run */
options obs=100;

/*
  This bundle is intentionally self-contained: script.sas carries its own
  mock claims data inline, so it also runs on its own via a single POST
  (see the copy-paste example in the PR). This autoexec only sets the row
  cap that the other bundles share.
*/
