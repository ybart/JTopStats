function buildChart(data) {
	var chart = new Highcharts.Chart({
		credits: {enabled: false},
		chart: {
			renderTo: 'chart-container',
			zoomType: 'xy',
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
		lang: {resetZoom: 'Zoom out'},
		series: data.series
	})

	//chart.toolbar.add('reset zoom')
  var xExtremes = chart.xAxis[0].getExtremes();
  var yExtremes = chart.yAxis[0].getExtremes();

	chart.xAxis[0].setExtremes(data.xAxis.min,data.xAxis.max)
	chart.yAxis[0].setExtremes(data.yAxis.min-1, Math.min(data.yAxis.min+250, data.yAxis.max + 1))

	chart.toolbar.add('zoom', 'Zoom out', 'View all data', function() {
	  chart.xAxis[0].setExtremes(xExtremes.min, xExtremes.max)
	  chart.yAxis[0].setExtremes(yExtremes.min, yExtremes.max)
	  chart.toolbar.remove('zoom')
	})

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
					$.fancybox('<div id="chart-container"></div><div id="chart-options"></div>');
					buildChart(data)
				},
				error: function(data, status, xhr) {
				    $.fancybox(data.responseText)
				}
			});

		return false
	})
})
