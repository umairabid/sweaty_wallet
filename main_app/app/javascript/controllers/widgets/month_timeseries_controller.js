import BaseController from "controllers/base_controller";
import * as d3 from "d3";
import element_available_width from "../../lib/element_available_width";

export default class extends BaseController {
  connect() {
    this.dates = JSON.parse(this.element.dataset.dates).map((d) => new Date(d));
    this.expenses = JSON.parse(this.element.dataset.expenses).map((d) =>
      Number(d)
    );
    this.incomes = JSON.parse(this.element.dataset.incomes).map((d) =>
      Number(d)
    );
    this.draw();
  }

  draw() {
    const width = this.available_width();
    const height = 300;
    const margin = 40;

    const all_trans = this.expenses.concat(this.incomes)

    const x = d3
      .scaleTime()
      .domain(d3.extent(this.dates))
      .range([margin, width - margin]);


    const y = d3
      .scaleLinear()
      .domain(d3.extent(all_trans))
      .range([height - margin, margin]);

    const line = d3
      .line()
      .x((d) => x(d.date))
      .y((d) => y(d.value));

    const svg = d3
      .select(this.element)
      .append("svg")
      .attr("width", width)
      .attr("height", height);

    // Add the x-axis.
    svg
      .append("g")
      .attr("transform", `translate(0,${height - margin})`)
      .call(d3.axisBottom(x));

    // Add the y-axis.
    svg
      .append("g")
      .attr("transform", `translate(${margin},0)`)
      .call(d3.axisLeft(y));

    // Add the line.
    svg
      .append("path")
      .datum(this.expenses.map((d, i) => ({ date: this.dates[i], value: d })))
      .attr("fill", "none")
      .attr("stroke", "red")
      .attr("stroke-width", 1.5)
      .attr("d", line);

    svg
      .append("path")
      .datum(this.incomes.map((d, i) => ({ date: this.dates[i], value: d })))
      .attr("fill", "none")
      .attr("stroke", "green")
      .attr("stroke-width", 1.5)
      .attr("d", line);

    this.element.append(svg.node());
  }

  available_width() {
    return element_available_width(this.element);
  }
}
