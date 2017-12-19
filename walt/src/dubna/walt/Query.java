package dubna.walt;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletRequest;
import dubna.walt.util.*;

import javax.servlet.http.HttpServlet;

//public class Query implements Runnable

/**
 *
 * @author serg
 */
public class Query
{

private ResourceManager rm = null;
private HttpServletRequest req = null;
private HttpServletResponse res = null;
private String queryLabel = null;
private long timer;


/** Constructor.
     * @param req
     * @param res
     * @param rm_Global
     * @param queryLabel
     * @param servlet
     * @throws javax.servlet.ServletException
     * @throws java.io.IOException
 */
public Query ( HttpServletRequest req
             , HttpServletResponse res
             , ResourceManager rm_Global
             , String queryLabel
             , HttpServlet servlet)
                throws ServletException, IOException
{
  this.rm = rm_Global.cloneRM();
  this.queryLabel=queryLabel;

  rm.setObject("rm_Global", rm_Global);
  rm.setObject("request", req);
  rm.setObject("response", res);
  rm.setObject("queryLabel", queryLabel);
  rm.setObject("Servlet", servlet);
  
	try
  {
//    System.out.println(queryLabel + " - RUN() ");
    timer = System.currentTimeMillis() / 10;
    String s = req.getServletPath() + "?" + req.getQueryString();
    s = decodeURIComponent(s);
/*    if (s.indexOf("&debug=") > 0)
      s = s.substring(0, s.indexOf("&debug=")) + ";...";
    if (s.indexOf("&tm=") > 0)
      s = s.substring(0, s.indexOf("&tm=")) + ";...";
    System.out.println(". " + queryLabel + " " + Fmt.lsDateStr((new java.util.Date()))
      + " " + StrUtil.unescape(s));
/**/      
//    Thread thisThread = Thread.currentThread();
//    thisThread.setPriority(Thread.MAX_PRIORITY-1);
//    thisThread.setName(queryLabel);
    rm.setParam("queryLabel", queryLabel);
//    if(1 == 1)
 //     throw (new Exception("AAA"));
//    System.out.println("\n\r Make query thread...");
    QueryThread t = makeQueryThread(rm);
    t.start();

//    String name = queryLabel;
//    String name = thisThread.getName();
//    if (name.length() > 30) name.substring(0, 20);
//    thisThread.setName("Finished! <small>(" + name + ")</small>");
//    System.out.println(queryLabel + ": " + (System.currentTimeMillis() / 10 - timer) / 100. + " sec.");
  }
  catch (Exception e)
  {
    if (! (e instanceof java.net.SocketException))
    {
      System.out.println("EXCEPTION: " + e.getMessage());
      e.printStackTrace(System.out);
      try
      {
        PrintWriter outWriter = new PrintWriter(res.getOutputStream());
        outWriter.println("</center><H3> Servlet error - </h3>" + e.getMessage() + "<pre>");
        e.printStackTrace(outWriter);
        outWriter.close();
      }
      catch (Exception ex)
      {
      System.out.println("-------");
        ex.printStackTrace(System.out);
      }
    }
  }
  finally
  {
this.rm = null;
this.req = null;
this.res = null;
this.queryLabel = null;

//  System.gc();
  }
}

    /**
     *
     * @param rm
     * @return
     * @throws Exception
     */
    public QueryThread makeQueryThread (ResourceManager rm) throws Exception
{
  /* --- make QueryThread object --- */
  String className = rm.getString("QueryThreadClass");
  if (className.length() == 0) // set the default QueryThread class
    className = "dubna.walt.SimpleQueryThread";
// System.out.println("----- makeQueryThread... '" + className + "'");
  Class cl = Class.forName(className);
  QueryThread t = (QueryThread)(cl.newInstance());
  t.init(rm);
  return t;
}
public static String decodeURIComponent(String encodedURI) {
  char actualChar;
 
  StringBuffer buffer = new StringBuffer();
 
  int bytePattern, sumb = 0;
 
  for (int i = 0, more = -1; i < encodedURI.length(); i++) {
   actualChar = encodedURI.charAt(i);
 
   switch (actualChar) {
    case '%': {
     actualChar = encodedURI.charAt(++i);
     int hb = (Character.isDigit(actualChar) ? actualChar - '0'
       : 10 + Character.toLowerCase(actualChar) - 'a') & 0xF;
     actualChar = encodedURI.charAt(++i);
     int lb = (Character.isDigit(actualChar) ? actualChar - '0'
       : 10 + Character.toLowerCase(actualChar) - 'a') & 0xF;
     bytePattern = (hb << 4) | lb;
     break;
    }
    case '+': {
     bytePattern = ' ';
     break;
    }
    default: {
     bytePattern = actualChar;
    }
   }
 
   if ((bytePattern & 0xc0) == 0x80) { // 10xxxxxx
    sumb = (sumb << 6) | (bytePattern & 0x3f);
    if (--more == 0)
     buffer.append((char) sumb);
   } else if ((bytePattern & 0x80) == 0x00) { // 0xxxxxxx
    buffer.append((char) bytePattern);
   } else if ((bytePattern & 0xe0) == 0xc0) { // 110xxxxx
    sumb = bytePattern & 0x1f;
    more = 1;
   } else if ((bytePattern & 0xf0) == 0xe0) { // 1110xxxx
    sumb = bytePattern & 0x0f;
    more = 2;
   } else if ((bytePattern & 0xf8) == 0xf0) { // 11110xxx
    sumb = bytePattern & 0x07;
    more = 3;
   } else if ((bytePattern & 0xfc) == 0xf8) { // 111110xx
    sumb = bytePattern & 0x03;
    more = 4;
   } else { // 1111110x
    sumb = bytePattern & 0x01;
    more = 5;
   }
  }
  return buffer.toString();
 }
    
}