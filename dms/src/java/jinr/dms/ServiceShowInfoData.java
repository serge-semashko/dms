package jinr.dms;

import java.sql.ResultSet;
import dubna.walt.util.IOUtil;
import java.sql.ResultSetMetaData;

/**
 * ������ ������������ ��� ������ ����������� � pop-up ���� ��� ������ ������
 * ��������� ������ ����, ��������� ��� ��������� ������������� �����������
 */
public class ServiceShowInfoData extends ServiceViewInfoData
{


	private String[] fields_order = null;
	private String orderByField = null;

	/**
	 * �������� ����� ������� - ���������� ������� ��������� �������.
	 *
	 * @throws Exception
	 */
	public void start () throws Exception
	{
		try
		{
			// �������� ������ ����� �����������, �� �������� � ���� �� �������� �����������
			// (��������� ���������� �������� � ������ [preSQLs] .cfg - �����)
			fields = cfgTuner.getParameter( "FIELDS" ).split( "," );
			fields_names = cfgTuner.getParameter( "FIELDS_NAMES" ).split( "," );
			fields_types = cfgTuner.getParameter( "FIELDS_TYPES" ).split( "," );
		  fields_order = cfgTuner.getParameter( "FIELDS_ORDER" ).split( "," );
		  orderByField = cfgTuner.getParameter( "orderByField" );
		  
			numFields = cfgTuner.getIntParameter( "NUM_FIELDS" );

			// ��������� ��������� �������� �������
			String h = "";
			for( int i = 0; i < numFields; i++ )
				{
				int order = Integer.parseInt( fields_order[i] );
				if( order > 0 ) //���� ������������ 
				{
					h = h + "<th>" + fields_names[i] + "</th>"; // - ������ ���������
					if( orderByField == null || orderByField.isEmpty())
						orderByField = fields[i];
				}
			cfgTuner.addParameter( "TableColsHeaders", h );
			}
			cfgTuner.outCustomSection( "report header", out ); // ������� ������ ������� ������� ��������� ��������
			showInfoRecords(); // ���������� ������ �����������
		}
		catch( Exception e )
		{
			e.printStackTrace( System.out );
			IOUtil.writeLogLn( "XXXXXXXX Exception: " + e.toString(), rm );
			cfgTuner.addParameter( "ERROR", e.toString() );
		}
		finally
		{
			cfgTuner.outCustomSection( "report footer", out );
			out.flush();
		}
	}
 

	/**
	 * ������������, ���������� ������� � ����
	 * � ����� HTML-������� ������� �����������
	 *
	 * @throws Exception
	 */
	protected void showInfoRecords () throws Exception
	{
		// ������������ SQL-������ � ����
		String fields = cfgTuner.getParameter( "FIELDS" );
		fields = fields.substring( 0, fields.length() - 1 );
		makeSearchCriteria();
		//	�������� ����� ���-�� �������, �����. �������� ������.	
		String s = "select count(*) as NUM_RECORDS from " + cfgTuner.getParameter( "TABLE_NAME" ) + " " + cfgTuner.getParameter( "CRITERIA" );
		ResultSet r = dbUtil.getResults( s ); // ��������� ������
		if( r.next() )
		{
			int tot_num_recs = r.getInt( 1 );
			r.close();
		  cfgTuner.addParameter( "TOT_NUM_RECS", Integer.toString( tot_num_recs ) );
			if( tot_num_recs > 0 )
			{
				int start_rec = cfgTuner.getIntParameter( null, "START_REC", 1 ); //��������� ������
				if( start_rec < 1 )
					start_rec = 1;
				int isrn = start_rec - 1;
				int irpp = cfgTuner.getIntParameter( null, "irpp", 20 ); // ���-�� ������� �� ��������
				//			  cfgTuner.addParameter( "START_REC", Integer.toString( isrn+1 ) );
				int lastRec = isrn+irpp;
				if( lastRec > tot_num_recs )
					lastRec = tot_num_recs;
			  cfgTuner.addParameter( "END_REC", Integer.toString( lastRec ) );

				//	������ �� ������� ������
				s = "select " + cfgTuner.getParameter( "FIELDS" ) + cfgTuner.getParameter( "SYS_FIELDS" ) 
						+ " from " + cfgTuner.getParameter( "TABLE_NAME" ) + " " 
						+ cfgTuner.getParameter( "CRITERIA" ) + " order by " + orderByField 
						+ " LIMIT " + isrn + "," + irpp;
				IOUtil.writeLogLn( "+++ GET RECORDS SQL: '" + s + "'", rm );
				r = dbUtil.getResults( s ); // ��������� ������
				ResultSetMetaData metaData = r.getMetaData();
				numCols = metaData.getColumnCount();

				int numRecs = 0;
				while( r.next() ) // ���� �� ���������� �������
				{
					String record = "";
					String val = "";
					for( int i = 1; i <= numFields; i++ ) // ���� �� ����� ������
					{
					  val = r.getString( i );
						if( !fields_order[i - 1].equals( "0" ) )
						{ //���� ������������
					    if( fields_types[i - 1].equals( "int" ) )
					      record += "<td class='right'>" + val + "</td>"; //��������� HTML
					    else if( fields_types[i - 1].equals( "varchar" ) )
					      record += "<td>" + markSearchItems(val) + "</td>";
							else
								System.out.println( " !!!!! UNKNOWN TYPE: " + fields_types[i - 1] );
						}
						
						if( i == 1 ) 
							cfgTuner.addParameter( "returnId", val ); // ���������� 1-� �� ������� ����, ��� ID
					  else if( i == 2 ) 
					    cfgTuner.addParameter( "returnValue", val ); // ���������� 2-� �� ������� ����, ��� �����
					}
					cfgTuner.addParameter( "recordId", Integer.toString( r.getInt( numFields + 1 ) ) ); //� ����� ���� ID ������ � �����������
					cfgTuner.addParameter( "record", record ); // ������� � Tuner ���������� ������
//					for( int i = numFields + 1; i <= numCols; i++ ) // �������� ���������� ��������� (�� ������������) ����
//						cfgTuner.addParameter( metaData.getColumnLabel( i ), r.getString( i ) ); // � ������ �� � Tuner. ���� ��� �� ������������. �� ������ ������, ���������.
					cfgTuner.outCustomSection( "item", out ); // ������� ������
					numRecs++;
				}
				r.close();
				if( numRecs == irpp )
					cfgTuner.addParameter( "HAS_NEXT", "Y" );
				if( isrn > 0 )
					cfgTuner.addParameter( "HAS_PREV", "Y" );
			}
		}
	}

	protected void addSearchCriteria ( String searchSubstring )
{
		// 
		if( searchSubstring.length() < 1 )
			return;
		String[] all_fields = cfgTuner.getParameter( "ALL_FIELDS" ).split( "," );
		String[] all_fields_types = cfgTuner.getParameter( "ALL_FIELDS_TYPES" ).split( "," );
		String searchFor = cfgTuner.getParameter( "searchFor" );
		Integer i_searchFor = null;
		try
		{
			i_searchFor = Integer.parseInt( searchSubstring );
		}
		catch( NumberFormatException nfe )
		{
			i_searchFor = null;
		}
		String f = "";
		for( int i = 0; i < all_fields.length; i++ )
		{
			if( all_fields_types[i].equals( "int" ) )
			{
				if( i_searchFor != null )
					f += " or " + all_fields[i] + "=" + searchSubstring;
			}
			else
				f += " or " + all_fields[i] + " like ('%" + searchSubstring + "%')";
		}
		if( f.length() > 4 )
		{
			String criteria = cfgTuner.getParameter( "CRITERIA" );
			if( criteria.length() < 1 )
				criteria = " where ";
			else
				criteria += " and ";
			criteria += "(" + f.substring( 4 ) + ")";
			cfgTuner.addParameter( "CRITERIA", criteria );
		}
	}

}
