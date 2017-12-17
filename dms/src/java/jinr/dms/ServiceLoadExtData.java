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
 * ������ ��� �������� ������������ �� ������� ���� ������
 * 
 */
public class ServiceLoadExtData extends dubna.walt.service.Service
{

	private PreparedStatement checkStmt = null;
	private PreparedStatement updateStmt = null;
	private PreparedStatement okStmt = null;
	private Vector vData = null;

	private int nr;
	private int numSrcCols = 0;
	private String[] dest_fields_types = null;
	private String[] dest_fields = null;
	private String[] dest_fields_names = null;
	private int numDestCols = 0;

	/**
	 * �������� ����� - ���������� ��� ������.
	 * @throws Exception
	 */
	public void start () throws Exception
	{
		ResultSet r = null;
		DBUtil srcDBUtil = null;
		try
		{
			cfgTuner.outCustomSection( "report header", out );
			//		� [report header] DB ������������� �� ������� DB ��� ������� �����������
			srcDBUtil = dbUtil;
			String request = cfgTuner.getParameter( "REQUEST" );
			//		�������� ResultSet � �������� ������� ��� �����������
			r = srcDBUtil.getResults( cfgTuner.getParameter( "REQUEST" ) );
		}
		catch( Exception e )
		{
			e.printStackTrace( System.out );
			IOUtil.writeLogLn( "XXXXXXXX Exception: " + e.toString(), rm );
			cfgTuner.addParameter( "ERROR", e.toString() );
			r = null;
		}

		try
		{
			if( r != null )
			{
//					String[] headers = DBUtil.getColNames(r);
				ResultSetMetaData metaData = r.getMetaData();
				numSrcCols = metaData.getColumnCount();

				dest_fields = cfgTuner.getParameter( "DEST_FIELDS" ).split( "," );
				dest_fields_names = cfgTuner.getParameter( "DEST_FIELDS_NAMES" ).split( "," );
				dest_fields_types = cfgTuner.getParameter( "DEST_FIELDS_TYPES" ).split( "," );
			  numDestCols = dest_fields.length;
			  useDb( "" ); // ����� ���������� ������� ������� � ����� ����

//			   System.out.println( "+++ numSrcCols=" + numSrcCols + "; numDestCols=" + numDestCols );

				String h_dest = "";
				for( int i = 0; i < numDestCols; i++ )
				{
					h_dest += "<td>" + dest_fields_names[i] + "</td>";
				}
			  String s = "";
			  String h_src = "";
			  for( int i = 0; i < numSrcCols; i++ )
			  {
			    s += "?, "; // ��������� ��� updateStmt - ������ ���-�� "?" �� ���-�� SRC-�����
			    h_src += "<td>" + dest_fields_names[i] + "</td>";
			  }

				cfgTuner.addParameter( "h_dest", h_dest ); // �������� ����� ��������� (��� ��������� �������)
				cfgTuner.addParameter( "h_src", h_src ); // �������� ����� ��������� (����� �������)
			  cfgTuner.outCustomSection( "start load", out ); // ������� ��������� ������� 

// ������� prepareStatement-� ��� ������ � ���������� ����� �������
				Connection conn = dbUtil.getConnection();
				conn.setAutoCommit( true );

				String sql = "select " + cfgTuner.getParameter("DEST_FIELDS" ) + " IS_MANUAL from " + cfgTuner.getParameter( "TABLE_NAME" ) + " where id=?" ;
			  IOUtil.writeLogLn( "+++ CHECK RECORD SQL: '" + sql +"'", rm );
				checkStmt = conn.prepareStatement( sql );

				String destImportedFields = "";
			  for (int i=0; i < numSrcCols; i++) 
				{
				  destImportedFields += dest_fields[i] + ", ";
				}
			  sql = "replace into " + cfgTuner.getParameter( "TABLE_NAME" ) + " (" + destImportedFields + " changed, is_deleted) values (" + s + " now(), 0)" ;
			  IOUtil.writeLogLn( "+++ UPDATE RECORD SQL: '" + sql +"'", rm );
				updateStmt = conn.prepareStatement( sql );

				okStmt = conn.prepareStatement( "update " + cfgTuner.getParameter( "TABLE_NAME" ) + " set is_deleted=0 where is_manual=0 and id=?" );

				vData = new Vector( numSrcCols ); // ���� ����� ���������� ����� ������ ��� insert ��� update
				while( r.next() )  // ���� �� ���������� �������
				{
					processRecord( r );
					nr++;
				}

				srcDBUtil.closeResultSet( r );  // ��������� �������� �������,
				srcDBUtil.close();  // ������� ������ �� �����

				showExtraRecords("DELETED");
			  showExtraRecords("MANUAL");
//			 showManualRecords();
//				showDeletedRecords();  // ���������� ����������� ������, ������� �������� �� ��������
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
			cfgTuner.outCustomSection( "report footer", out );
			out.flush();
		}
	}
	
/**
	 * 
	 * @param r
	 * @throws Exception
	 */
	protected void processRecord ( ResultSet r ) throws Exception
	{
		vData.clear(); // ���������� ������ ����� ������
		cfgTuner.addParameter( "newData", "" ); // � ��������� ��� �� ������
		cfgTuner.addParameter( "oldData", "" );
		if( !checkRecord( r ) )  // �������� ��������� � ������
		{
			for( int i = 1; i <= numSrcCols; i++ )  // ���������� ������ � prepareStatement ��� ����������
			{
				if( dest_fields_types[i - 1].equals( "int" ) )
					updateStmt.setInt( i, ( ( Integer ) vData.elementAt( i - 1 ) ).intValue() );
				else if( dest_fields_types[i - 1].equals( "varchar" ) )
					updateStmt.setString( i, ( String ) vData.elementAt( i - 1 ) );
			}
			updateStmt.executeUpdate();  // ��������� (��� ���������) ������
			cfgTuner.outCustomSection( "item", out );  // ���������� ������
		}
		else
		{
			okStmt.setInt( 1, ( ( Integer ) vData.elementAt( 0 ) ).intValue() );
			okStmt.executeUpdate(); // �������� ������, ��� ����������
		  cfgTuner.outCustomSection( "item", out );  // ���������� ������
		}
	}
	
 
 /**
	 * ������� ������� "������" ������ � ������, ���������� �� ��������
	 * 
	 * @param extraType - ��� ������� ("DELETED" ��� "MANUAL")
	 * @throws Exception
	 */
	 private void showExtraRecords(String extraType) throws Exception
	 {
		 cfgTuner.addParameter( "RECORD", extraType );
		 cfgTuner.addParameter( "newData", "" );
		 Connection conn = dbUtil.getConnection();
		 String sql = "select " + cfgTuner.getParameter( "DEST_FIELDS" ) + "is_manual from " + cfgTuner.getParameter( "TABLE_NAME" );
		 if(extraType.equals("DELETED"))
				sql += " where is_deleted=1 and is_manual=0";
	   else if(extraType.equals("MANUAL"))
	     sql += " where is_deleted=0 and is_manual=1";
		 IOUtil.writeLogLn( "+++ " + extraType + " SQL: '" + sql + "'", rm );
		 PreparedStatement delStmt = conn.prepareStatement( sql );
		 ResultSet r = delStmt.executeQuery();
		 while( r.next() )
		 {
			 String oldData = "";
			 for( int i = 1; i <= numDestCols; i++ )
			 {
				 if( dest_fields_types[i - 1].equals( "int" ) )
					 oldData += "<td>" + r.getInt( i ) + "</td>";
				 else if( dest_fields_types[i - 1].equals( "varchar" ) )
					 oldData += "<td>" + r.getString( i ) + "</td>";
				 else
					 System.out.println( " !!!!! UNKNOWN TYPE: " + dest_fields_types[i - 1] );
	 //        if(i<numSrcCols)
	 //          newData += "<td>-</td>";
			 }
			 cfgTuner.addParameter( "oldData", oldData );
			 cfgTuner.outCustomSection( "item", out );
		 }
	 }

/**
	 * �� ������������
	 * @throws Exception
	 *
	private void showDeletedRecords() throws Exception
	{
		cfgTuner.addParameter( "RECORD", "DELETED" );
	  cfgTuner.addParameter( "newData", "" );
		Connection conn = dbUtil.getConnection();
		String sql = "select " + cfgTuner.getParameter( "DEST_FIELDS" ) + "is_manual from " + cfgTuner.getParameter( "TABLE_NAME" ) + " where is_deleted=1 and is_manual=0";
	  IOUtil.writeLogLn( "+++ DELETED SQL: '" + sql + "'", rm );
		PreparedStatement delStmt = conn.prepareStatement( sql );
		ResultSet r = delStmt.executeQuery();
		while( r.next() )
		{
			String oldData = "";
			for( int i = 1; i <= numDestCols; i++ )
			{
				if( dest_fields_types[i - 1].equals( "int" ) )
					oldData += "<td>" + r.getInt( i ) + "</td>";
				else if( dest_fields_types[i - 1].equals( "varchar" ) )
					oldData += "<td>" + r.getString( i ) + "</td>";
				else
					System.out.println( " !!!!! UNKNOWN TYPE: " + dest_fields_types[i - 1] );
//				if(i<numSrcCols)
//					newData += "<td>-</td>";
			}
 System.out.println( "+++ DELETED: oldData=" + oldData );
			cfgTuner.addParameter( "oldData", oldData );
			cfgTuner.outCustomSection( "item", out );
		}
	}
/**/

/** �� ������������
	private void showManualRecords() throws Exception
	{
		cfgTuner.addParameter( "RECORD", "MANUAL" );
	  cfgTuner.addParameter( "newData", "" );
		Connection conn = dbUtil.getConnection();
	  String sql = "select " + cfgTuner.getParameter( "DEST_FIELDS" ) + "is_manual from " + cfgTuner.getParameter( "TABLE_NAME" ) + " where is_manual=1";
//	  is_deleted=0 and 
	  IOUtil.writeLogLn( "+++ MANUAL SQL: '" + sql + "'", rm );
		PreparedStatement manualStmt = conn.prepareStatement( sql );
		ResultSet r = manualStmt.executeQuery();
		while( r.next() )
		{
			String oldData = "";
			for( int i = 1; i <= numDestCols; i++ )
			{
				if( dest_fields_types[i - 1].equals( "int" ) )
					oldData += "<td>" + r.getInt( i ) + "</td>";
				else if( dest_fields_types[i - 1].equals( "varchar" ) )
					oldData += "<td>" + r.getString( i ) + "</td>";
				else
					System.out.println( " !!!!! UNKNOWN TYPE: " + dest_fields_types[i - 1] );
	//        if(i<numSrcCols)
	//          newData += "<td>-</td>";
			}
	 System.out.println( "+++ MANUAL: oldData=" + oldData );
			cfgTuner.addParameter( "oldData", oldData );
			cfgTuner.outCustomSection( "item", out );
		}
	}
/**/
	
	/**
	 * �������� ������ �� ���������
	 * @param r
	 * @return
	 * @throws Exception
	 */
	private boolean checkRecord ( ResultSet r ) throws Exception
	{
		boolean isEqual = true;
		int id = r.getInt( 1 );
		int iv = 0;
		String sv = "";
		int ivOld = 0;
		String svOld = "";
	  String oldData = "";
	  String newData = "<td>" + id + "</td>";
		vData.addElement( id );
		checkStmt.setInt( 1, id );
		ResultSet checkResultSet = checkStmt.executeQuery();
		cfgTuner.addParameter( "newData", cfgTuner.getParameter( "newData" ) + "<td>" + id + "</td>" );
		if( checkResultSet != null && checkResultSet.next() ) // record exists
		{
		  oldData = "<td>" + id + "</td>";
			for( int i = 2; i <= numSrcCols; i++ )
			{
				if( dest_fields_types[i - 1].equals( "int" ) )
				{
					iv = r.getInt( i );
					ivOld = checkResultSet.getInt( i );
					vData.addElement( iv );
				  oldData += "<td>" + ivOld + "</td>";
				  newData += "<td>" + iv + "</td>";
					if( iv != ivOld )
						isEqual = false;
				}
				else if( dest_fields_types[i - 1].equals( "varchar" ) )
				{
					sv = r.getString( i ).trim();
					svOld = checkResultSet.getString( i );
					vData.addElement( sv );
				  oldData += "<td>" + svOld + "</td>";
				  newData += "<td>" + sv + "</td>";
					if( !sv.equals( svOld ) )
						isEqual = false;
				}
				else
					System.out.println( " !!!!! UNKNOWN TYPE: " + dest_fields_types[i - 1] );
			}
		  for( int i = numSrcCols+1; i <= numDestCols; i++ )
		  {
		    if( dest_fields_types[i - 1].equals( "int" ) )
		    {
		      ivOld = checkResultSet.getInt( i );
//		      vData.addElement( iv );
		      oldData += "<td>" + ivOld + "</td>";
		    }
		    else if( dest_fields_types[i - 1].equals( "varchar" ) )
		    {
		      svOld = checkResultSet.getString( i );
		      oldData += "<td>" + svOld + "</td>";
		    }
		    else
		      System.out.println( " !!!!! UNKNOWN TYPE: " + dest_fields_types[i - 1] );
		  }


		  int is_manual = checkResultSet.getInt( numDestCols + 1 );
			if(is_manual == 1) isEqual = true;

			if( isEqual )
				cfgTuner.addParameter( "RECORD", "OLD" );
			else
				cfgTuner.addParameter( "RECORD", "UPDATED" );
		}
		else // new record
		{
			cfgTuner.addParameter( "RECORD", "NEW" );
		  oldData = "<td>-</td>";
			for( int i = 2; i <= numSrcCols; i++ )
			{
				if( dest_fields_types[i - 1].equals( "int" ) )
				{
					vData.addElement( r.getInt( i ) );
				  newData += "<td>" + r.getInt( i ) + "</td>";
				}
				else if( dest_fields_types[i - 1].equals( "varchar" ) )
				{
					vData.addElement( r.getString( i ).trim() );
				  newData += "<td>" + r.getString( i ) + "</td>";
				}
				else
					System.out.println( " !!!!! UNKNOWN TYPE: " + dest_fields_types[i - 1] );
				oldData += "<td>-</td>";
			}
		  isEqual = false;
		}
//	  oldData += "<td></td>";
	  cfgTuner.addParameter( "oldData", oldData  );
	  cfgTuner.addParameter( "newData", newData );
	  return isEqual;

	}

}
