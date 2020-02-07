package io.xspec.xspec.ant.taskdefs;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;

/**
 * Ant task to convert URL to file path
 *   cf. https://stackoverflow.com/q/26539422
 *   Reverse to <makeurl> task:
 *     https://github.com/apache/ant/blob/master/src/main/org/apache/tools/ant/taskdefs/MakeUrl.java
 */
public class MakePath extends Task {
  private String property;
  private String url;

  /**
   * Sets the name of a property to fill with the file path
   *
   * @param property the name of the property
   */
  public void setProperty(String property) {
    this.property = property;
  }

  /**
   * Sets a URL to be converted into a file path
   *
   * @param url the URL to be converted
   */
  public void setUrl(String url) {
    this.url = url;
  }

  /**
   * Converts a URL to a file path
   *
   * @throws BuildException
   *          if something goes wrong with the build
   */
  public void execute() throws BuildException {
    validate();

    // Exit if the property is already set
    if (getProject().getProperty(property) != null) {
      return;
    }

    URL url;
    try {
      url = new URL(this.url);
    } catch (MalformedURLException e) {
      throw new BuildException(e);
    }

    URI uri;
    try {
      uri = url.toURI();
    } catch (URISyntaxException e) {
      throw new BuildException(e);
    }

    File file = new File(uri);
    String path = file.toString();

    log("Setting " + property + " to file path " + path, Project.MSG_VERBOSE);
    getProject().setNewProperty(property, path);
  }

  private void validate() {
    if(property == null) {
      throw new BuildException("@property not defined");
    }
    if(url == null) {
      throw new BuildException("@url not defined");
    }
  }
}
