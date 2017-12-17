package jinr.dms;

import dubna.walt.util.IOUtil;
import dubna.walt.util.Tuner;

/**
 * �������� � �������������� ������ ���������
 */
public class ServiceEditDocData extends dubna.walt.service.TableServiceSpecial {

	private int numFields = 0;
	private String[] fields = null;
	private String[] fields_types = null;
	private String[] form_fields_types = null;
	private String sql = "";

	/**
	 * �������� ����� ������� - ���������� ������� ��������� �������.
	 *
	 * @throws Exception
	 */
	@Override
	public void start() throws Exception {
		try {
			initSuper(); // ����� ������������ ����� ��������������� ����������� ����������
			cfgTuner.outCustomSection("report header", out); // ����� ������ �����

//    �������� ������ ����� ���������, �� �������� � ���� �� �������� ���� ���������
// (��������� ���������� �������� � ������ [preSQLs] .cfg - �����)
			fields = cfgTuner.getParameter("FIELDS").split(",");
			fields_types = cfgTuner.getParameter("FIELDS_TYPES").split(",");
			form_fields_types = cfgTuner.getParameter("FORM_FIELDS_TYPES").split(",");
			numFields = fields.length;

			if (cfgTuner.enabledOption("cop=save")) {
				doSave(); // ���������� ������ �� ������ "���������"
			}
			if (!cfgTuner.enabledOption("cop") // ����������� �����, ���� �������� ���
			  || cfgTuner.enabledOption("ERROR")) { // ��� ���� ������ ����������
// ������������ SQL ��� ������� �������� ����� ���������
				sql = "select ";
				for (int i = 0; i < numFields; i++) {
					sql += fields[i] + ", ";
					if (form_fields_types[i].equals("4")) {
						sql += fields[i] + "_id, ";
					}
				}

				sql += cfgTuner.getParameter("SYS_FIELDS")
						+ " from " + cfgTuner.getParameter("TABLE_NAME")
						+ " where id=" + cfgTuner.getParameter("DOC_DATA_RECORD_ID");
				IOUtil.writeLogLn("=================", rm);
				IOUtil.writeLogLn("+++ Get info record data SQL: " + sql, rm);
				IOUtil.writeLogLn("=================", rm);
// ��������� ������ � ����
				getPreData(sql);
// ������ ����� ��������������				
				cfgTuner.outCustomSection("start form", out);
// ������� ���� ����� � ������ ���������
				makeTable();
			}

		} catch (Exception e) {
			e.printStackTrace(System.out);
			IOUtil.writeLogLn("XXXXXXXX Exception: " + e.toString(), rm);
			cfgTuner.addParameter("ERROR", e.toString());
		} finally {
// ������� ���������� ����� 
			cfgTuner.outCustomSection("report footer", out);
			out.flush();
		}
	}

	/**
	 * ���������� ����� ��������� � ��
	 *
	 * @throws Exception
	 */
	private void doSave() throws Exception {
// ������������ ������ SQL ������� - ������ ���� ����� ������
		String fds = "";
		for (int i = 0; i < numFields; i++) {
			fds += fields[i] + ", ";
			if (form_fields_types[i].equals("4")) { // ���������� - ��������� ID 
				fds += fields[i] + "_id, ";
			} else if (form_fields_types[i].equals("7")) {  // ����� - ��������� ������
				fds += fields[i] + "_curr, ";
			}
		}
		IOUtil.writeLogLn("+++ FIELDS: '" + fds + "'", rm);

		sql = "replace into " + cfgTuner.getParameter("TABLE_NAME") + " (id, " // SQL ���������� ����� ���������
				+ fds
				+ cfgTuner.getParameter("SYS_FIELDS_UPDATE")
				+ ") values (" + cfgTuner.getParameter("DOC_DATA_RECORD_ID");;

// ��������� � ������� ����� " values (...) " � ������� �� �����
		for (int i = 0; i < numFields; i++) {
			sql += ", " + makeParamValue(fields[i], fields_types[i], cfgTuner);
			if (form_fields_types[i].equals("4")) {  // ���������� - ��������� ID 
				sql += ", " + makeParamValue(fields[i] + "_id", "int", cfgTuner);
			} else if (form_fields_types[i].equals("7")) {  // ����� - ��������� ������
				sql += ", " + makeParamValue(fields[i] + "_curr", "varchar", cfgTuner);
			}
		}

// ��������� � ������� ����� " values (...) " �� �������� ������
		String[] sysFields = cfgTuner.getParameter("SYS_FIELDS_UPDATE").split(",");
		String[] sysFieldsTypes = cfgTuner.getParameter("SYS_FIELDS_UPDATE_TYPES").split(",");
		for (int i = 0; i < sysFields.length; i++) {
			sql += ", " + makeParamValue(sysFields[i], sysFieldsTypes[i], cfgTuner);
		}
		sql += ")";

		IOUtil.writeLogLn("+++ UPDATE RECORD SQL: '" + sql + "'", rm);
//	������� ��������� ������
		getPreData(sql);

	}

	/**
	 *
	 * ���������� �������� ��������� � ������� � ����� SQL ������� � �����������
	 * �� ���� ���� ��������, ����� ���������� �� ������ ������, ������� �����
	 * ������ STATIC. � ����������� - ���������� � �������� � �����-������ �����
	 * ���� "utils"
	 *
	 * @param paramName - ��� ��������� � Tuner, � ������� ����� ������ ��������
	 * @param paramType - ��� �������� (int, boolean, varchar, date, datetime
	 * ��� sysdate
	 * @param cfgTuner - Tuner, � ������� ��������
	 * @return �������� ���������, �������������� � ������� � SQL ������. int -
	 * ��� ����, varchar - � ��������, date � datetime - �������������� ��
	 * ������ � ���� �� ������������ �������, sysdate => now()
	 */
	public static String makeParamValue(String paramName, String paramType, Tuner cfgTuner) {
		String paramValue = cfgTuner.getParameter(paramName.trim());
		if (paramValue.length() == 0) {
			if (paramType.equals("int") || paramType.equals("boolean")
					|| paramType.equals("date") || paramType.equals("datetime")) {
				return "null";
			}
		}
		if (paramType.equals("int")) {
			return paramValue;
		} else if (paramType.equals("float")) {
			return paramValue;
		} else if (paramType.equals("boolean")) {
			return (paramValue.equals("on") || paramValue.equals("1")) ? "1" : "0";
		} else if (paramType.equals("varchar")) {
			return "'" + paramValue + "'";
		} else if (paramType.equals("dir")) {
			return "'" + paramValue + "'";
		} else if (paramType.equals("date")) {
			return "STR_TO_DATE('" + paramValue + "','" + cfgTuner.getParameter("dateFormat") + "')";
		} else if (paramType.equals("datetime")) {
			return "STR_TO_DATE('" + paramValue + "','" + cfgTuner.getParameter("dateTimeFormat") + "')";
		} else if (paramType.equals("sysdate")) {
			return "now()";
		} else {
			System.out.println("!!! UNKNOWN DATA FORMAT: " + paramType);
			return paramValue;
		}
	}

	/**
	 * ����� ������ ��� ����������� - ����� ��� ��� �� ������������.
	 *
	 * @throws Exception
	 */
	private void initSuper() throws Exception {
		makeTableTuner();
		initFormatParams();
		makeTotalsForCols = "";
		makeSubtotals = false;
		unicodeHeaders = false;
		initTableTagsObjects();
	}

}
