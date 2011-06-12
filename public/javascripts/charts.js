function buildChart(data) {
	chart = new Highcharts.Chart({
		credits: {enabled: false},
		chart: {
			renderTo: 'chart-container',
			defaultSeriesType: 'line',
			marginRight: 230,
			marginBottom: 25
		},
		title: {
			text: 'Évolution du classement de clips au cours des J-Tops',
			x: -20 //center
		},
		subtitle: {
			text: 'Source: Nolife',
			x: -20
		},
		xAxis: {
			allowDecimals: false,
		},
		yAxis: {
			min: data.yAxis.min-1,
			max: Math.min(data.yAxis.min+250, data.yAxis.max + 1),
			reversed: true,
			allowDecimals: false,
			title: {
				text: 'Classement'
			},
			plotBands: [
				{
					from: 10,
					to: 20,
					color: '#003000'
				},	
				{
					from: 0,
					to: 10,
					color: '#007000'
				}
			]
		},
		tooltip: {
			formatter: function() {
				return '<b>'+ this.series.options.fullname +'</b><br/>'+
				'J-Top ' + this.x +': n°'+ this.y;
			}
		},
		legend: {
			layout: 'vertical',
			backgroundColor: '#000',
			color: 'white',
			align: 'right',
			align: 'right',
			verticalAlign: 'bottom',
			x: -10,
			y: -50,
			borderWidth: 0,
		},
		series: data.series
	})
	
	console.log(data.yAxis.min+100, data.yAxis.max + 1, Math.min(data.yAxis.min+100, data.yAxis.max + 1))
	
	$('svg > path').attr('fill-opacity', 0.3)
	$('svg > .highcharts-legend > rect').attr('fill-opacity', 0.3)
}

$(function() {
	$('form input.chart').click(function(){
		form = $(this)[0].form
		$.fancybox.showActivity();
		
		$.ajax({
				type	: form.method,
				cache	: false,
				url		: form.action,
				data	: $(form).serialize(),
				dataType: 'json',
				success: function(data, status, xhr) {
					$.fancybox('<div id="chart-container"></div>');
					buildChart(data)
				},
				error: function(data, status, xhr) {
				    $.fancybox(data.responseText)
				}
			});
		
		return false
	})
})
