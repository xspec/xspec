/*
	Converts URL to file path.
	cf. https://stackoverflow.com/q/26539422
*/
var javaURL = new java.net.URL(attributes.get("url"));
var javaFile = new java.io.File(javaURL.toURI());
var path = javaFile.toString();
self.project.setProperty(attributes.get("property"), path);
