package jinr.sed;

import dubna.walt.util.IOUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashSet;
import java.util.Set;
import jinr.sed.tools.CommonTools;
import static jinr.sed.ServiceViewDocForm.typesNeedIdField;

/**
 * Просмотр и редактирование данных документа
 */
public class ServiceEditDocData extends dubna.walt.service.TableServiceSpecial {

    private int numFields = 0;
    private String[] fields = null;
    private String[] fields_types = null;
    private String[] form_fields_types = null;
    private String sql = "";
 /*
    public static final Set<String> typesNeedIdField = new HashSet<String>() {
        {
            add("3");
            add("4");
            add("6");
            add("1001");
            add("1003");
            add("1009");
            add("1011");
            add("1012");
            add("1017");
            add("1024");
            add("1028");
        }
    };
/**/
/*    
    public static final Set<String> typesIsCollection = new HashSet<String>() {
        {
            add("1004");
            add("1014");
            add("1016");
            add("1022");
            add("1025");           
        }
    };
    
    /**/

    /**
     * Основной метод сервиса - определяет порядок обработки запроса.
     *
     * @throws Exception
     */
    @Override
    public void start() throws Exception {
        try {
            initSuper(); // чтобы родительский класс инициализировал необходимые переменные
            cfgTuner.outCustomSection("report header", out); // вывод начала формы

//    получаем список полей документа, их названия и типы из описания типа документа
// (результат выполнения запросов в секции [preSQLs] .cfg - файла)
            fields = cfgTuner.getParameter("FIELDS").split(",");
            fields_types = cfgTuner.getParameter("FIELDS_TYPES").split(",");
            form_fields_types = cfgTuner.getParameter("FORM_FIELDS_TYPES").split(",");
            numFields = fields.length;

            if (cfgTuner.enabledExpression("cop=save&!ERROR")) {
                doSave(); // сохранение записи по кнопке "Сохранить", если не было обнаружено ошибок
            }
            if (cfgTuner.enabledExpression("!cop|ERROR|INPUT_ERROR")) { // отображение формы, если действия нет или есть ошибка 
                if (!cfgTuner.enabledExpression("ERROR|INPUT_ERROR")) {  // если нет ошибки (т.е. !cop) - вытаскиваем сохраненные данные
// конструируем SQL для выборки значений полей документа
                    IOUtil.writeLogLn(3, "+++ ServiceEditDocData.makeSelectSQL()", rm); 
                    sql = "select ";
                    for (int i = 0; i < numFields; i++) {
                        sql += fields[i] + ", ";
                        if (typesNeedIdField.contains(form_fields_types[i])) {
                            sql += fields[i] + "_id, ";
                        }
                        IOUtil.writeLogLn(3, "..." + i + ":" + fields[i] + "/" + form_fields_types[i] + " / " + sql, rm);
                    }

                    sql += cfgTuner.getParameter("SYS_FIELDS")
                            + " from " + cfgTuner.getParameter("TABLE_NAME")
                            + " where id=" + cfgTuner.getParameter("DOC_DATA_RECORD_ID");
                    IOUtil.writeLogLn("=================", rm);
                    IOUtil.writeLogLn("++++++++++ ServiceEditDocData.Get doc data SQL: " + sql, rm);
                    IOUtil.writeLogLn("=================", rm);
// выполняем запрос к базе
                    getPreData(sql);
                }
// начало формы редактирования				
                cfgTuner.outCustomSection("start form", out);
// выводим саму форму с полями документа
                makeTable();
            }

        } catch (Exception e) {
            e.printStackTrace(System.out);
            IOUtil.writeLogLn("XXXXXXXX Exception: " + e.toString(), rm);
            cfgTuner.addParameter("ERROR", e.toString());
        } finally {
// выводим завершение формы 
            cfgTuner.outCustomSection("report footer", out);
            out.flush();
        }
    }

    /**
     * Сохранение полей документа в БД
     *
     * @throws Exception
     */
    private void doSave() throws Exception {
// Конструируем начало SQL запроса - список всех полей записи

        sql = "update " + cfgTuner.getParameter("TABLE_NAME") + " set "; // SQL обновления полей документа
        String comma = "";

// добавляем к запросу часть " name=value " с данными из формы
        for (int i = 0; i < numFields; i++) {
            if (!form_fields_types[i].equals("1") && !form_fields_types[i].equals("6")) { // статический текст и file - не трогаем. Обновляется самостоятельно
                String val = CommonTools.makeParamValue(fields[i], fields_types[i], cfgTuner);
                IOUtil.writeLogLn(3, i + ": (" +fields_types[i] + ", " + cfgTuner.getParameter(fields[i].trim()) + ") " + fields[i] + "='" + val + "'", rm);
                if (val != null) {
                    sql += comma + fields[i] + "=" + val;
                    comma = ", ";
                }
                if (typesNeedIdField.contains(form_fields_types[i])) { // справочник - сохраняем ID 
                    sql += comma + fields[i] + "_id = " + CommonTools.makeParamValue(fields[i] + "_id", "varchar", cfgTuner);
                }
//                if (form_fields_types[i].equals("7")) {  // сумма - сохраняем валюту
//                    sql += comma + fields[i] + "_curr = " + CommonTools.makeParamValue(fields[i] + "_curr", "varchar", cfgTuner);
//                }
//		IOUtil.writeLogLn(i + ": " + form_fields_types[i] + ": " + fields[i] + "=" + CommonTools.makeParamValue(fields[i], "varchar", cfgTuner) , rm);
//		IOUtil.writeLogLn(i + ": " + sql, rm);
            }
        }

// добавляем к запросу часть " name=value " для скрытых полей
//				+ cfgTuner.getParameter("SYS_FIELDS_UPDATE")
        String[] sysFields = cfgTuner.getParameter("SYS_FIELDS_UPDATE").split(",");
        String[] sysFieldsTypes = cfgTuner.getParameter("SYS_FIELDS_UPDATE_TYPES").split(",");
        for (int i = 0; i < sysFields.length; i++) {
            sql += ", " + sysFields[i] + " = " + CommonTools.makeParamValue(sysFields[i], sysFieldsTypes[i], cfgTuner);
        }

        sql += " where id=" + cfgTuner.getParameter("DOC_DATA_RECORD_ID");

        IOUtil.writeLogLn("+++++ UPDATE RECORD SQL: '" + sql + "'", rm);
//	Наконец выполняем запрос
        getPreData(sql);
        setDocIndex();
    }

    /**
     * Обновление таблицы индексирования документа для полнотекстового поиска
     */
    private void setDocIndex() {
        String tf = cfgTuner.getParameter("DOC_TEXT_FIELDS");
        if (tf.length() > 0) {
            try {
                String[] text_fields = tf.split(",");
                String[] text_names = cfgTuner.getParameter("DOC_TEXT_NAMES").split(",");

                sql = "replace into d_index (doc_id, context) values (" + cfgTuner.getParameter("doc_id") + ", ?)";
                IOUtil.writeLogLn("+++ UPDATE INDEX SQL: '" + sql + "'", rm);

                Connection conn = dbUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);

                String context = cfgTuner.getParameter("TITLE");
                for (int i = 0; i < text_fields.length; i++) {
                    if (cfgTuner.enabledOption(text_fields[i])) {
                        context += " / " + text_names[i] + ": " + cfgTuner.getParameter(text_fields[i]);
                    }
                }
                context += " ' / Комментарий: '" + cfgTuner.getParameter("comment");

                IOUtil.writeLogLn("+++ UPDATE INDEX VALUE: <xmp>'" + context + "'</xmp>", rm);
                stmt.setString(1, context);
                stmt.executeQuery();
            } catch (Exception e) {
                e.printStackTrace(System.out);
            }
        }
    }

    /**
     * нужно только для суперкласса - здесь это все не используется.
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
