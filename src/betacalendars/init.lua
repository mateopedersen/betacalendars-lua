local date = require("betacalendars.date")
local grid = require("betacalendars.grid")
local year = require("betacalendars.year")
local range = require("betacalendars.range")
local recurrence = require("betacalendars.recurrence")
local business = require("betacalendars.business")
local boundary = require("betacalendars.boundary")

return {
  version = "1.0.0",
  is_leap_year = date.is_leap_year,
  days_in_month = date.days_in_month,
  validate_date = date.validate,
  weekday = date.weekday,
  weekday_name = date.weekday_name,
  iso_week = date.iso_week,
  iso_date = date.iso_date,
  add_days = date.add_days,
  compare_dates = date.compare,
  month_grid = grid.month_grid,
  year_grid = year.year_grid,
  date_range = range.date_range,
  recurrence = recurrence,
  expand_recurrence = recurrence.expand,
  is_weekend = business.is_weekend,
  is_business_day = business.is_business_day,
  business_days_between = business.business_days_between,
  next_business_day = business.next_business_day,
  previous_business_day = business.previous_business_day,
  boundary_report = boundary.boundary_report,
  export = {
    csv = require("betacalendars.export.csv"),
    markdown = require("betacalendars.export.markdown"),
    json = require("betacalendars.export.json")
  }
}
