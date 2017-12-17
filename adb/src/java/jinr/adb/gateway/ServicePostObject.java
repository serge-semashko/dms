package jinr.adb.gateway;

import dubna.walt.util.IOUtil;
import dubna.walt.util.gateway.Utils;

/**
 *
 * @author serg
 */
public class ServicePostObject extends dubna.walt.service.Service {

    String[] fields_types;
    long timer;

    /**
     *
     * @throws Exception
     */
    @Override
    public void start() throws Exception {
        timer = System.currentTimeMillis();
        try {
            cfgTuner.getCustomSection("getObject"); // ������ �������

// ������� ��������� �������
            String encodedData = Utils.getEncodedSection("request", rm);
            IOUtil.writeLogLn("<hr><b>request:</b>" + encodedData, rm);

// ������� ��� JSON �� �������
            String[] sa = cfgTuner.getCustomSection("object");
            if (sa != null && sa.length > 0) {  // ���� ������ ���� - ��������� ���� ������
                encodedData += "&Object={" + Utils.getEncodedJSON("object", rm, true) + "}";
            }
            
            cfgTuner.addParameter("encodedData", encodedData);  //��� �������

            long t1 = System.currentTimeMillis();
            IOUtil.writeLogLn("<hr>***** TIMER 1 (prepare data): " + Long.toString(t1 - timer), rm);

// �������� ������ � ������ �����             
            String responce = Utils.postRequest(cfgTuner.getParameter("GatewayHost"), encodedData, rm);
            IOUtil.writeLogLn("RESPONCE:" + responce, rm);
            long t2 = System.currentTimeMillis();
            IOUtil.writeLogLn("***** TIMER 2 (post data): " + Long.toString(t2 - t1), rm);

            cfgTuner.addParameter("responce", responce);
            if(Utils.parseJson(responce, rm) == null) cfgTuner.addParameter("ERROR", "������ ������� ������!");
        } catch (Exception e) {
            e.printStackTrace(System.out);
            IOUtil.writeLogLn("XXXXXXXX Exception: " + e.toString(), rm);
            cfgTuner.addParameter("ERROR", e.toString());
            cfgTuner.addParameter("Result", e.toString());
        } finally {
// ����� ����������
            cfgTuner.outCustomSection("report", out);
            out.flush();
        }
    }

}
