import BaseController from "controllers/base_controller";
import * as d3 from "d3";
import element_available_width from "lib/element_available_width";

export default class extends BaseController {
  connect() {
    this.chart_data = JSON.parse(this.element.dataset.chart_data);
    this.create_chart();
  }

  create_chart() {
    const width = 400;
    const height = 200;
    const radius = Math.min(width, height) / 2 - 40; // Reduced radius to make space for labels

    const svg = d3
      .select(this.element)
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", `translate(${width / 2}, ${height / 2})`); // Center the pie chart

    const pie = d3
      .pie()
      .value((d) => d.value)
      .sort(null); // No sorting

    const arc = d3.arc().innerRadius(0).outerRadius(radius);

    // Arc for positioning the text labels, slightly outside the main pie
    const labelArc = d3
      .arc()
      .innerRadius(radius + 15) // Adjust this value to control label distance
      .outerRadius(radius + 15);

    const color = d3.scaleOrdinal(d3.schemeCategory10);

    // Draw the pie slices
    svg
      .selectAll("path")
      .data(pie(this.chart_data))
      .enter()
      .append("path")
      .attr("d", arc)
      .attr("fill", (d, i) => color(i));
    // Removed the stroke attributes: .attr("stroke", "white").style("stroke-width", "2px"); // No stroke/divider between pies

    // --- Add Labels ---

    svg
      .selectAll("text")
      .data(pie(this.chart_data))
      .enter()
      .append("text")
      .attr("transform", (d) => `translate(${labelArc.centroid(d)})`) // Position text using labelArc
      .attr("text-anchor", (d) => {
        // Set text-anchor based on whether the label is on the left or right side of the pie
        const midangle = d.startAngle + (d.endAngle - d.startAngle) / 2;
        return midangle < Math.PI ? "start" : "end";
      })
      .attr("fill", (d, i) => color(i)) // Set text color to match slice color
      .text((d) => d.data.name + " (" + d.data.value + "%)") // Display name and value with percentage
      .style("dominant-baseline", "middle"); // Vertically center text
  }
}
