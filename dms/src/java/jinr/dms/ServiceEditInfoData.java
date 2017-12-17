package jinr.dms;

import dubna.walt.util.IOUtil;
import dubna.walt.util.Tuner;

/**
 * �������� � �������������� ����� ������ �����������
 */
public class ServiceEditInfoData extends dubna.walt.service.TableServiceSpecial
{

	private int nr;
	private int numFields = 0;
//	private final int numCols = 0;
	private String[] fields_types = null;
	private String[] fields = null;
//	private String[] fields_names = null;
	private String sql="";

	/**
	 * �������� ����� ������� - ���������� ������� ��������� �������.
	 *
	 * @throws Exception
	 */
        @Override
	public void start () throws Exception
	{
		try
		{
		  initSuper(); // ����� ������������ ����� ��������������� ����������� ����������
		  cfgTuner.outCustomSection( "report header", out ); // ����� ������ �����

//    �������� ������ ����� �����������, �� �������� � ���� �� �������� �����������
// (��������� ���������� �������� � ������ [preSQLs] .cfg - �����)
		  fields = cfgTuner.getParameter( "FIELDS" ).split( "," );
//		  fields_names = cfgTuner.getParameter( "FIELDS_NAMES" ).split( "," );
		  fields_types = cfgTuner.getParameter( "FIELDS_TYPES" ).split( "," );
		  numFields = cfgTuner.getIntParameter("NUM_FIELDS");

			if(cfgTuner.enabledOption("cop=save")){
				doSave(); // ���������� ������ �� ������ "���������"
			}
			else {  // ����� - ����������� �����
// ������������ SQL ��� ������� �������� ����� ������ �����������
				sql = "select ";  
				for( int i = 0; i < numFields; i++ ) 
					sql += fields[i] +  ", ";
				sql += cfgTuner.getParameter( "SYS_FIELDS" )  
					+ " from " + cfgTuner.getParameter("TABLE_NAME") 
					+ " where id=" + cfgTuner.getParameter("record_id");			
			  IOUtil.writeLogLn( "+++ Get info record data SQL: " + sql, rm );
// ��������� ������ � ����
				getPreData(sql);

// ������� ����� � ������ �����������
				makeTable(); 
			}
		
		}
		catch( Exception e )
		{
			e.printStackTrace( System.out );
			IOUtil.writeLogLn( "XXXXXXXX Exception: " + e.toString(), rm );
			cfgTuner.addParameter( "ERROR", e.toString() );
		}
		finally
		{
// ������� ���������� ����� 
			cfgTuner.outCustomSection( "report footer", out );
			out.flush();
		}
	}
	
/**
	 * ���������� � �� ����������� ������ �����������
	 * 
	 * @throws Exception
	 */
private void doSave()  throws Exception
{
// ������������ ������ SQL ������� - ������ ���� ����� ������
	sql = "replace into " + cfgTuner.getParameter("TABLE_NAME") + " ("   // SQL ��� ���������� �������� ����� ������ �����������
		+ cfgTuner.getParameter( "FIELDS" )
		+ cfgTuner.getParameter( "SYS_FIELDS_UPDATE" ) + ") values (";

// ��������� � ������� ����� " values (...) " � ������� �� �����
	String s = "";
	for( int i = 0; i < numFields; i++ ) 
		s += ", " + makeParamValue(fields[i], fields_types[i], cfgTuner);
	sql += s.substring(1);

// ��������� � ������� ����� " values (...) " � �������� ������
	String[] sysFields = cfgTuner.getParameter( "SYS_FIELDS_UPDATE" ).split(",");
	String[] sysFieldsTypes = cfgTuner.getParameter( "SYS_FIELDS_TYPES" ).split(",");
	s = "";
	for( int i = 0; i < sysFields.length; i++ ) 
			s += ", " + makeParamValue(sysFields[i], sysFieldsTypes[i], cfgTuner);
	sql += s + ")";	

	IOUtil.writeLogLn( "+++ UPDATE RECORD SQL: '" + sql +"'", rm );
//	������� ��������� ������
	getPreData(sql);
	
}

/**
	 * 
	 * ���������� �������� ��������� � ������� � ����� SQL ������� � ����������� �� ���� ����
	 * ��������, ����� ���������� �� ������ ������, ������� ����� ������ STATIC.
	 * � ����������� - ���������� � �������� � �����-������ ����� ���� "utils"
	 * 
	 * @param paramName - ��� ��������� � Tuner, � ������� ����� ������ ��������
	 * @param paramType - ��� �������� (int, boolean, varchar, date, datetime ��� sysdate
	 * @param cfgTuner - Tuner, � ������� ��������
	 * @return �������� ���������, �������������� � ������� � SQL ������. int - ��� ����, 
	 * varchar - � ��������, date � datetime - �������������� �� ������ � ���� �� ������������ �������, 
	 * sysdate => now()
	 */
public static String makeParamValue(String paramName, String paramType, Tuner cfgTuner) 
{
	String paramValue = cfgTuner.getParameter(paramName.trim());
	if( paramType.equals( "int" ) )
	  return paramValue;
	else if( paramType.equals( "boolean" ) )
		return (paramValue.equals("on") || paramValue.equals("1"))? "1": "0";
	else if( paramType.equals( "varchar" ) ) 
	  return "'" + paramValue + "'";
	else if( paramType.equals( "date" ) ) 
		return "'STR_TO_DATE('" + paramValue + "','" + cfgTuner.getParameter("dateFormat") + "')" ;
	else if( paramType.equals( "datetime" ) ) 
	  return "'STR_TO_DATE('" + paramValue + "','" + cfgTuner.getParameter("dateTimeFormat") + "')" ;
	else if( paramType.equals( "sysdate" ) ) 
		return "now()" ;
	else {
		System.out.println("!!! UNKNOWN DATA FORMAT: " + paramType);
		return paramValue;
	}
}

/**
	 * ����� ������ ��� ����������� - ����� ��� ��� �� ������������. 
	 * @throws Exception
	 */
private void initSuper() throws Exception
{
				makeTableTuner();
				initFormatParams();
				makeTotalsForCols = "";
				makeSubtotals = false;
				unicodeHeaders = false;
				initTableTagsObjects();	
}

}
