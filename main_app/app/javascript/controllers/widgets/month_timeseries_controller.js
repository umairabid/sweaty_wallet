import BaseController from "controllers/base_controller";
import * as d3 from "d3";
import element_available_width from "lib/element_available_width";

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

    const all_trans = this.expenses.concat(this.incomes);

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
      .attr("height", height)
      .style("overflow", "visible");

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

    const expensesData = this.expenses.map((d, i) => ({
      date: this.dates[i],
      value: d,
    }));
    const incomesData = this.incomes.map((d, i) => ({
      date: this.dates[i],
      value: d,
    }));

    // Add the lines.
    svg
      .append("path")
      .datum(expensesData)
      .attr("fill", "none")
      .attr("stroke", "red")
      .attr("stroke-width", 1.5)
      .attr("d", line);

    svg
      .append("path")
      .datum(incomesData)
      .attr("fill", "none")
      .attr("stroke", "green")
      .attr("stroke-width", 1.5)
      .attr("d", line);

    // Tooltip
    const tooltip = d3
      .select("body")
      .append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)
      .style("position", "absolute")
      .style("background-color", "white")
      .style("border", "1px solid black")
      .style("padding", "5px");

    // Add circles for expenses.
    svg
      .selectAll(".expense-circle")
      .data(expensesData)
      .enter()
      .append("circle")
      .attr("class", "expense-circle")
      .attr("cx", (d) => x(d.date))
      .attr("cy", (d) => y(d.value))
      .attr("r", 4)
      .attr("fill", "red")
      .style("cursor", "pointer")
      .on("mouseover", function (event, expensePoint) {
        const incomePoint = incomesData.find(
          (d) => d.date.getTime() === expensePoint.date.getTime()
        );

        tooltip.html(
          `Date: ${d3.timeFormat("%Y-%m-%d")(expensePoint.date)}<br>Expenses: ${expensePoint.value}<br>Income: ${incomePoint ? incomePoint.value : "N/A"}`
        );

        const tooltipWidth = tooltip.node().offsetWidth;
        const mouseX = event.pageX;

        let tooltipLeft = mouseX + 10;
        if (tooltipLeft + tooltipWidth > width) {
          tooltipLeft = mouseX - tooltipWidth - 10;
        }

        tooltip
          .style("left", tooltipLeft + "px")
          .style("top", event.pageY - 28 + "px")
          .style("opacity", 1);
      })
      .on("mouseout", function () {
        tooltip.style("opacity", 0);
      });

    // Add circles for incomes.
    svg
      .selectAll(".income-circle")
      .data(incomesData)
      .enter()
      .append("circle")
      .attr("class", "income-circle")
      .attr("cx", (d) => x(d.date))
      .attr("cy", (d) => y(d.value))
      .attr("r", 4)
      .attr("fill", "green")
      .style("cursor", "pointer")
      .on("mouseover", function (event, incomePoint) {
        const expensePoint = expensesData.find(
          (d) => d.date.getTime() === incomePoint.date.getTime()
        );

        tooltip.html(
          `Date: ${d3.timeFormat("%Y-%m-%d")(incomePoint.date)}<br>Expenses: ${expensePoint ? expensePoint.value : "N/A"}<br>Incomes: ${incomePoint.value}`
        );

        const tooltipWidth = tooltip.node().offsetWidth;
        const mouseX = event.pageX;

        let tooltipLeft = mouseX + 10;
        if (tooltipLeft + tooltipWidth > width) {
          tooltipLeft = mouseX - tooltipWidth - 10;
        }

        tooltip
          .style("left", tooltipLeft + "px")
          .style("top", event.pageY - 28 + "px")
          .style("opacity", 1);
      })
      .on("mouseout", function () {
        tooltip.style("opacity", 0);
      });

    this.element.append(svg.node());
  }

  available_width() {
    return element_available_width(this.element);
  }
}
