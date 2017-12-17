package jinr.dms;

import java.sql.ResultSet;
import dubna.walt.util.DBUtil;
import dubna.walt.util.IOUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Vector;

/**
 * author: �������
 */
public class ServiceTreeInfoData extends dubna.walt.service.Service {

    protected PreparedStatement checkStmt = null;

    protected int nr;
    protected int numFields = 0;
    protected int numCols = 0;
    protected String[] fields_types = null;
    protected String[] fields = null;
    protected String  dataSeparator = "~|~";
    protected String[] fields_names = null;

    protected String[] searchSubstrings = null;

    /**
     * �������� ����� ������� - ���������� ������� ��������� �������.
     *
     * @throws Exception
     */
    public void start() throws Exception {
        try {
			//  �������� ������ ����� �����������, �� �������� � ���� �� �������� �����������
            // (��������� ���������� �������� � ������ [preSQLs] .cfg - �����)
            dataSeparator = !cfgTuner.getParameter("DATA_SEPARATOR").isEmpty()?cfgTuner.getParameter("DATA_SEPARATOR"):dataSeparator;
            fields = cfgTuner.getParameter("FIELDS").split(",");
            fields_names = cfgTuner.getParameter("FIELDS_NAMES").split(",");
            fields_types = cfgTuner.getParameter("FIELDS_TYPES").split(",");
            numFields = cfgTuner.getIntParameter("NUM_FIELDS");
            cfgTuner.outCustomSection("report header", out); // ������� ������ ������� ������� ��������� ��������
            showInfoRecords(); // ���������� ������ �����������
        } catch (Exception e) {
            e.printStackTrace(System.out);
            IOUtil.writeLogLn("XXXXXXXX Exception: " + e.toString(), rm);
            cfgTuner.addParameter("ERROR", e.toString());
        } finally {
            cfgTuner.outCustomSection("report footer", out);
            out.flush();
        }
    }

    /**
     * ����� ������� ������� �����������
     *
     * @throws Exception
     */
    protected void showInfoRecords() throws Exception {
        // ������������ SQL-������ � ����
        String requesterId = cfgTuner.getParameter("requesterId");

        //  �������� ����� ���-�� �������, �����. �������� ������.  
        String s = "select count(*) as NUM_RECORDS from "
                + cfgTuner.getParameter("TABLE_NAME")
                + " " + cfgTuner.getParameter("CRITERIA");
        ResultSet r = dbUtil.getResults(s); // ��������� ������
        if (r.next()) {
            int tot_num_recs = r.getInt(1);
            r.close();
            cfgTuner.addParameter("TOT_NUM_RECS", Integer.toString(tot_num_recs));
            if (tot_num_recs > 0) {
                s = "select " + cfgTuner.getParameter("FIELDS")
                        + cfgTuner.getParameter("SYS_FIELDS")
                        + " from " + cfgTuner.getParameter("TABLE_NAME")
                        + " " + cfgTuner.getParameter("CRITERIA");
                IOUtil.writeLogLn("+++ GET RECORDS SQL: '" + s + "'", rm);
                r = dbUtil.getResults(s); // ��������� ������
                ResultSetMetaData metaData = r.getMetaData();
                numCols = metaData.getColumnCount(); // ���-�� ���������� ��������
                int id, pid;
                while (r.next()) // ���� �� ���������� �������, �������� �� ��� JSON ������
                {
                    id = r.getInt(1); // ������ ���� - ������ ID ������ 
                    pid = r.getInt(2); // ������ ���� - ������ PID ������
                    String sPid = pid >= 0 ? requesterId + pid : "#";
                    String sId = requesterId + id;
                    String record = "{\"id\" : \"" + sId + "\", \"parent\" : \"" + sPid + "\", \"text\" : \"";
                    String val = "";
                    for (int i = 3; i <= numFields; i++) // ���� �� ����� ������
                    {
                        //��������� ���� ������ � JSON ���� text ����� ���������
                        val += (i > 3 ? dataSeparator : "") + r.getString(i).replaceAll("\"", "\\\\\"");
                    }
                    record += val;
                    record += "\""
                            //+ ", \"zz\":\"xx\""
                            + "}, ";
                    cfgTuner.addParameter("record", record); // ������� � Tuner ���������� ������

                    cfgTuner.outCustomSection("item", out); // ������� ������
                }
                r.close();
            }
        }

    }

}
