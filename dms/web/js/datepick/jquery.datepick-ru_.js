/* http://keith-wood.name/datepick.html
   Russian localisation for jQuery Datepicker.
   Written by Andrew Stromnov (stromnov@gmail.com). */
(function($) {
	$.datepick.regionalOptions['ru'] = {
		monthNames: ['������','�������','����','������','���','����',
		'����','������','��������','�������','������','�������'],
		monthNamesShort: ['���','���','���','���','���','���',
		'���','���','���','���','���','���'],
		dayNames: ['�����������','�����������','�������','�����','�������','�������','�������'],
		dayNamesShort: ['���','���','���','���','���','���','���'],
		dayNamesMin: ['��','��','��','��','��','��','��'],
		dateFormat: 'dd.mm.yyyy', firstDay: 1,
		renderer: $.datepick.defaultRenderer,
		prevText: '&#x3c;����',  prevStatus: '',
		prevJumpText: '&#x3c;&#x3c;', prevJumpStatus: '',
		nextText: '����&#x3e;', nextStatus: '',
		nextJumpText: '&#x3e;&#x3e;', nextJumpStatus: '',
		currentText: '�������', currentStatus: '',
		todayText: '�������', todayStatus: '',
		clearText: '��������', clearStatus: '',
		closeText: '�������', closeStatus: '',
		yearStatus: '', monthStatus: '',
		weekText: '��', weekStatus: '',
		dayStatus: 'D, M d', defaultStatus: ''
//,		isRTL: false
	};
	$.datepick.setDefaults($.datepick.regionalOptions['ru']);
})(jQuery);
