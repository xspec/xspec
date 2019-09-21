echo Print Java version
java -version

echo Print Ant version
call ant -version

echo Print Saxon version
java -cp "%SAXON_JAR%" net.sf.saxon.Version

echo Print environment variables
set
