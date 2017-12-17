package jinr.pin;

import dubna.walt.util.*;

import java.io.*;
import java.util.*;
import java.sql.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.fileupload.util.*;

public class QueryThread extends dubna.walt.SimpleQueryThread {

    public DBUtil dbUtil = null;
    static public final String KEY_NAME = "name=\"";
    public boolean logIt = true;
//  ServletInputStream inpStream = null;

    public void start() // throws Exception
    {
        startTm = System.currentTimeMillis();
        // super.start();
        try {
            parseRequest(request);
            getAddresses();
            makeTuner();
            setContentType();
            dbUtil = makeDBUtil();
            logQuery();

            //    rm.setObject("cfgTuner", cfgTuner);
            if (!headOnly) {
                if (cfgTuner.enabledOption("ResetLog=true")) {
                    IOUtil.clearLogFile(rm);
                }

                //       writeHttpHeaders();
                HttpSession sess = ((HttpServletRequest) rm.getObject("request")).getSession();
                cfgTuner.addParameter("USER_ID", (String) sess.getAttribute("USER_ID"));
                super.validateUser();

//                         if(super.validateUser()){
//                             super.validateParameters();
                startService();
//                         }
            }
            registerQuery(null);
        } catch (Exception e) {
            logException(e);
            registerQuery(e);
        } finally {
            if (outWriter != null) {
                outWriter.flush();
                outWriter.close();
                try {
                    outStream.close();
                    //         inpStream.close();
                } catch (Exception e) { /* don't warry! */ }
            }

            finish();
        }
    }

    /**
     * Reads and parses the multipart form data from the ServletInputStream
     */
    public String getMultiPartData(HttpServletRequest request, Hashtable ht)
            throws Exception {
        if (ServletFileUpload.isMultipartContent(request)) {
            String allParams = MULTIPART_SEPARATOR;

            ServletFileUpload upload = new ServletFileUpload();
            ServletRequestContext rc = new ServletRequestContext(request);
            int contLength = rc.getContentLength();
            registerParameter("ContentLength", Long.toString(contLength), ht);
//			System.out.println("ContentLength: " + contLength + "; CharacterEncoding: " + rc.getCharacterEncoding());

            BufferedInputStream fileStream = null;
//	   InputStream fileStream = null;
            int bufLen = 64000;
            byte[] buf = new byte[bufLen];

            String name = "";
            String val = "";
            String filePath = "";
            String fileName = "";
            String contentType = "";

            FileItemIterator iter = upload.getItemIterator(request);
            while (fileStream == null && iter.hasNext()) {
                FileItemStream item = iter.next();
                name = item.getFieldName();
                InputStream stream = item.openStream();
                if (item.isFormField()) {
                    val = getAsString(stream, buf, bufLen);
                    if (val.length() > 0) {
                        registerParameter(name, val, ht);
//  System.out.println("Form field: '" + name + "'='"  + val  + "'");						              
                        allParams = allParams + name + "=" + val + MULTIPART_SEPARATOR;
                    }
                    name = "";
                    val = "";
                    //                + StreamUtil.asString(stream) + " detected.");
                } else {
                    filePath = item.getName();
                    if (filePath.length() > 1) {
                        fileName = FileContent.parseFilePath(filePath);;
	//System.out.println("File field " + name + " file name: '" + filePath + "' ContentType:" + item.getContentType() );

                        registerParameter(name + "_TYPE", FileContent.getFileType(fileName), ht);
                        contentType = item.getContentType();
                        registerParameter(name + "_CONTENT_TYPE", contentType, ht);
                        registerParameter(name, fileName, ht);
                        registerParameter(name + "_SRC", StrUtil.replaceInString(filePath, "\\", "/"), ht);
                        allParams = allParams + name + "=" + fileName + MULTIPART_SEPARATOR
                                + name + "_TYPE=" + FileContent.getFileType(fileName) + MULTIPART_SEPARATOR;

                        if (name.indexOf("BFILE_1") == 0) {
//								fileStream=stream;
                            fileStream = new BufferedInputStream(stream);
                            rm.setObject(name + "_STREAM", fileStream);
                        } else {
                            FileContent fc = new FileContent(stream, fileName, contentType, contLength);
                            rm.setObject(name + "_CONTENT", fc);
                            registerParameter(name + "_SIZE", Integer.toString(fc.getFileSize()), ht);
								//            fc.storeToDisk(rm.getString("AppRoot") + rm.getString("uploadPath"), filename);
                            //            fc.storeToDisk(cfgTuner.getParameter("AppRoot") + cfgTuner.getParameter("uploadPath"), filename);

                        }
                    }
                }
            }

	//		 String s = new String(buf, 0, n, clientEncoding); 
            //System.out.println("... bytes read. Total:" + numBytes + ". Content length:" + contLength + ". Rest:" + rest);
            params.addElement("multipart=yes");
            return allParams;
        } else {
            return "";
        }
    }

    public void logException(Exception e) {
        if (!(e instanceof java.net.SocketException)) {
            if (cfgTuner != null) {
                cfgTuner.addParameter("ERROR", e.toString());
            }
            if (srv == null || !srv.terminated) {
                if (outWriter == null) {
                    try {
                        outWriter = new PrintWriter(response.getOutputStream());
                    } catch (Exception ex) {;
                    }
                }

                if (outWriter != null
                        && (cfgTuner == null
                        || cfgTuner.enabledOption("debug=on")
                        || cfgTuner.getParameter("USER_GROUP").equalsIgnoreCase("SA"))) {
                    outWriter.println("<xmp>");
                    e.printStackTrace(outWriter);
                    outWriter.println("</xmp>");
                    logAll();
                }
                outWriter.println(e.toString());
            }
        }
    }
    /*
     @Override
     public void logQuery()
     { if (logIt)
     System.out.println(
     rm.getString("queryLabel") 
     + ": " + cfgTuner.getParameter("c")
     + ": " + cfgTuner.getParameter("USER_ID")
     + " (" + cfgTuner.getParameter("USER_ROLE")
     + ") " + cfgTuner.getParameter("ClientIP")
     + "; [" + Fmt.shortDateStr( new java.util.Date() ) + "] "
     );
     }
     /**/

    public String getAsString(InputStream in, byte[] buf, int bufLen) throws Exception {
        String s = "";
        int numBytes = 1;
        int bufPos = 0;
        while (numBytes > 0) {
            while (bufPos < bufLen && numBytes > 0) {
                numBytes = in.read(buf, bufPos, bufLen - bufPos);
                if (numBytes > 0) {
                    bufPos += numBytes;
                }
            }
            s += new String(buf, 0, bufPos, clientEncoding);
        }
        return s;
    }

    public void makeTuner() throws Exception {
        String cfg = cfgFileName;
        GregorianCalendar c = new GregorianCalendar();
        String now = Fmt.fmt(c.get(Calendar.YEAR), 4, Fmt.ZF) + "-"
                + Fmt.fmt(c.get(Calendar.MONTH) + 1, 2, Fmt.ZF) + "-"
                + Fmt.fmt(c.get(Calendar.DAY_OF_MONTH), 2, Fmt.ZF) + " "
                + Fmt.fmt(c.get(Calendar.HOUR_OF_DAY), 2, Fmt.ZF) + ":"
                + Fmt.fmt(c.get(Calendar.MINUTE), 2, Fmt.ZF) + ":"
                + Fmt.fmt(c.get(Calendar.SECOND), 2, Fmt.ZF);
        params.addElement("now=" + now);
        super.makeTuner();
        if (cfgTuner.enabledOption("reloadCfg=y")) {
            jinr.pin.Servlet sr = (jinr.pin.Servlet) rm.getObject("Servlet");
            sr.setResourceManager(sr.obtainResourceManager());
            System.out.println("+++++++ RM Reloaded; CFG:" + cfg);
            cfgFileName = cfg;
            cfgTuner.addParameter("c", cfg);
        }
//  System.out.println("......  cfgFileName:" + cfgFileName);
    }

    public void startService() throws Exception {
        if (checkClientIP()) {
            super.startService();
        }
    }

    public boolean checkClientIP() {
        StringTokenizer st = null;
        String blocked_ip = cfgTuner.getParameter("blocked_ip");
        String ip = cfgTuner.getParameter("ClientIP");
        String ip_mask = cfgTuner.getParameter("ip_mask");
        if (ip_mask.length() > 0) {
            st = new StringTokenizer(ip_mask, ",");
            while (st.hasMoreTokens()) {
                String s = st.nextToken();
                if (ip.indexOf(s) == 0) {
                    return true;
                }
            }
            System.out.println("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX BLOCKED IP: " + ip);
            return false;
        }

        if (blocked_ip.length() > 0) {
            st = new StringTokenizer(blocked_ip, ",");
            while (st.hasMoreTokens()) {
                String s = st.nextToken();
                if (ip.indexOf(s) == 0) {
                    System.out.println("ZZZZZZZZZZZZZZZZXXXXXXXXXXXXXXXXXX BLOCKED IP: " + ip);
                    return false;
                }
            }
        }

        return true;
    }

    public synchronized DBUtil makeDBUtil() throws Exception {
        if (cfgFileName.indexOf("css/") == 0
                || cfgFileName.indexOf("info/contacts.cfg") == 0
                || cfgFileName.indexOf("info/prikaz.cfg") == 0
                || cfgFileName.indexOf("empty.cfg") == 0) {
            logIt = false;
            return null;
        }
        if (cfgFileName.indexOf("showIcon.cfg") == 0
                || cfgFileName.indexOf("login.cfg") == 0
                || cfgFileName.indexOf("showPhoto.cfg") == 0) {
            logIt = false;
        }

        if (!cfgTuner.enabledOption("connString")) {
            return null;
        }
        Class.forName(rm.getString("dbDriver"));        // init the JDBC driver
        try {
            /* Establish connection to the database and make DBUtil */
            if (cfgTuner.enabledOption("debug=on")) {
                System.out.println("  connect:" + cfgTuner.getParameter("connString")
                        + cfgTuner.getParameter("database") + cfgTuner.getParameter("connParam")
                        + " //|| " + cfgTuner.getParameter("usr") + "/*** "
                //	+ cfgTuner.getParameter("pw")
                );
            }
            dbUtil = new DBUtil(cfgTuner.getParameter("connString")
                    + cfgTuner.getParameter("database")
                    + cfgTuner.getParameter("connParam"),
                    cfgTuner.getParameter("usr"),
                    cfgTuner.getParameter("pw"),
                    queryLabel, 1);
            dbUtil.nrConnsToKeep = 3;
            dbUtil.db = DBUtil.DB_MySQL;
            dbUtil.allocate();

            Connection conn = dbUtil.getConnection();
            conn.setAutoCommit(false);
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("set max_sp_recursion_depth=30");
//	   stmt.executeUpdate("SET NAMES cp1251");
//	   stmt.executeUpdate("set max_allowed_packet=5000000");
            conn.commit();
            stmt.close();
            rm.setObject("DBUtil", dbUtil, false);
            //    rm.setObject("DBUtil", dbUtil, true);
        } catch (Exception e) {
            System.out.println("Connection to " + cfgTuner.getParameter("connString") + " FAILED!...");
//		 e.printStackTrace(System.out);
            cfgTuner.addParameter("NotConnected", "Y");
            if (outWriter != null) {
                cfgTuner.addParameter("ERR_MSG", e.getMessage());
                cfgTuner.addParameter("ERR_MSG_DES",
                        "Could not connect to the Database " + cfgTuner.getParameter("connString"));
            }
            /*		 if (outWriter != null)
             { outWriter.println("<small>" +  e.getMessage() + "</small>");
             outWriter.println("<center><table border=1 bgcolor=#FFEEBB cellpadding=8><tr><th>"
             + "Could not connect to the Database '" + cfgTuner.getParameter("connString") + "!</th></tr></table></center><p>");
             outWriter.flush();
             }
             */ e.printStackTrace(System.out);
            return null;
        }
        if (cfgTuner.enabledOption("debug=on")) {
            System.out.println(" OK!...");
        }
        return dbUtil;
    }

    private String trimString(String s, int maxLen) {
        return s.substring(0, Math.min(s.length(), maxLen));
    }

    protected void registerQuery(Exception e) {
        String c = cfgTuner.getParameter("c");
//        System.out.println("+++ logQuery +++ c=" + c + "; e=" + e);
//        if (!logIt) {
//            return;
//        }
//        svs/info_show_dd,svs/showWfStepTooltip,free/checkSession_noDB,sys/showLog_noDB,
//        ,wf/show_wf_for_doc,wf/graph_show_wf_for_doc,sys/checkAdminRights,wf/show_wf_status,docs/out_files_list,docs/doc_files_list,docs/doc_field_file,sys/request_log,
        if (excludeFromLog.contains("," + c + ",")) {
            return;
        }
        dbUtil = (DBUtil) rm.getObject("DBUtil", false);
        if (dbUtil == null || !dbUtil.isAlive()) {
            try {
                dbUtil = makeDBUtil();
            } catch (Exception ex) {
                System.out.println("+++ logQuery: ERROR! " + ex.toString());
                ex.printStackTrace(System.out);
            }
        }
        if (dbUtil == null) {
            System.out.println("c="+cfgTuner.getParameter("c"));
            System.out.println("+++ logQuery: ERROR! dbUtil is null!");
        } else if (cfgTuner == null) {
            System.out.println("+++ logQuery: ERROR! cfgTuner is null!");
        } else {
            try {
                String err = trimString(cfgTuner.getParameter("ERROR"), 1900);
//	    System.out.println("+++ logQuery +++ err=" + err + "; ");
                String request_name = trimString(cfgTuner.getParameter("request_name"), 64);

                Connection conn = dbUtil.getConnection();
                conn.setAutoCommit(true);
                String s = "insert into a_req_log (USER_ID, C, REQUEST_NAME, QUERY, DOC_ID, COOKIES, ERR, DAT, IP, USER_AGENT, REF, SESS_ID, SESS, DID, TIM, REAL_USER_ID) values (?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(s);
                stmt.setInt(1, cfgTuner.getIntParameter(null, "USER_ID", 0));
                stmt.setString(2, c);
                stmt.setString(3, request_name);
                stmt.setString(4, trimString(cfgTuner.getParameter("queryString"), 2047));
                stmt.setInt(5, cfgTuner.getIntParameter(null, "doc_id", 0));
                stmt.setString(6, trimString(cfgTuner.getParameter("h_cookie"), 2047));
                if (e == null) {
                    stmt.setString(7, err);
                } else {
                    stmt.setString(7, e.toString() + " / " + err);
                }
                stmt.setString(8, cfgTuner.getParameter("ClientIP"));
                stmt.setString(9, cfgTuner.getParameter("h_user-agent"));
                stmt.setString(10, cfgTuner.getParameter("h_referer"));
                stmt.setInt(11, cfgTuner.getIntParameter(null, "SESS_ID", 0));
                stmt.setString(12, cfgTuner.getParameter("q_JSESSIONID"));
                stmt.setString(13, cfgTuner.getParameter("q_cwldid"));
                long l = System.currentTimeMillis() - startTm;
                stmt.setInt(14, (int) l);
                stmt.setInt(15, cfgTuner.getIntParameter(null, "VU", 0));
                stmt.executeUpdate();

            } catch (Exception ex) {
                System.out.println("+++ logQuery: STORE ERROR! " + ex.toString());
                ex.printStackTrace(System.out);
            }
        }
    }

    @Override
    protected void finish() {
        closeDBUtils();
        if (cfgTuner != null) {
            try {
                if (cfgTuner.enabledOption("debug=on")) {
                    System.out.println("\n" + "[" + Fmt.lsDateStr(new java.util.Date()) + "] "
                            + rm.getString("queryLabel") + ": --- finish()");
                }
            } catch (Exception e) {;
            }
        }
    }

    protected void closeDBUtils() {
        if (dbUtil != null) {
            try {
                if (cfgTuner.enabledOption("ERROR")) {
                    dbUtil.update("ROLLBACK");
                } else {
                    dbUtil.update("COMMIT");
                }
            } catch (Exception e) {
            }
            dbUtil.release();
            dbUtil.close();
        }

        dbUtil = (DBUtil) rm.getObject("DBUtil", false);
        if (dbUtil != null) {
            dbUtil.release();
            dbUtil.close();
            rm.setObject("DBUtil", null);
        }
        dbUtil = null;
//  System.out.println("---------------- closeDBUtils() " + queryLabel);
    }

}
