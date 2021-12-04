view: pop_block {
#  label: "Timeline Comparison Fields"

extension: required

dimension: getdate_func {
  hidden: yes
  description: "This only exists to be nested in the current_date dimension. Having this field seperate allows for timezone conversion of the current date."
  type: date
  sql:getdate();;
  convert_tz: yes
}

dimension: getdate_or_user_set_date {
  hidden: yes
  description: "This dimension acts as a middle step allowing the use of a user selectable date for 'today' instead of the default result from getdate()"
  type: date
  convert_tz: no # Note that if TZ conversion is needed, it will have happened in the getdate_func dimension.
  sql: case when date({% parameter as_of_date%}) = date(getdate()) or {% parameter as_of_date%} is null then ${getdate_func} else {% parameter as_of_date%} end ;;

}

dimension: current_date_dim {
  view_label: "Timeline Comparison Fields"
  description: "This field exists because of the way Looker handles timezone conversions. If the conversion occurs after dateadd things get wonky and you get extra days."
  # type:
  hidden:  yes
  # Important note. This must be get_date, not current_date. current_date can't be timezone converted as it has no time. The system will assume midnight for the
  # conversion leading to bad results.
  sql:
  date({% case exclude_days._parameter_value %}
         {% when "999" %}
            case when date({% parameter as_of_date%}) = date(getdate()) then (select max(${origin_event_date}) from ${origin_table_name})
            else {% parameter as_of_date%} end
         {% when "1" %}
            date_add('days', -1, ${getdate_or_user_set_date})
         {% when "2" %}
            date_add('days', -2, ${getdate_or_user_set_date})
         {% when "start_of_week" %}
            dateadd('days', -1, date_trunc('week', ${getdate_or_user_set_date}))
         {% when "start_of_month" %}
            dateadd('days', -1, date_trunc('month', ${getdate_or_user_set_date}))
         {% when "start_of_quarter" %}
            dateadd('days', -1, date_trunc('quarter', ${getdate_or_user_set_date}))
         {% when "start_of_year" %}
            dateadd('days', -1, date_trunc('year', ${getdate_or_user_set_date}))
         {% else %}
            ${getdate_or_user_set_date}
       {% endcase %});;
    # convert_tz: no
  }

  dimension: period_1_start_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_1_start} ;;
    convert_tz: no
  }

  dimension: period_1_end_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_1_end} ;;
    convert_tz: no
  }

  measure: period_1_len {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: number
    sql: datediff(${period_1_start},${period_1_end}) ;;
  }

  dimension: period_2_start_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_2_start} ;;
    convert_tz: no
  }

  dimension: period_2_end_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_2_end} ;;
    convert_tz: no
  }

  measure: period_2_len {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: number
    sql: datediff(${period_2_start},${period_2_end}) ;;
  }

  dimension: period_3_start_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_3_start} ;;
    convert_tz: no
  }

  dimension: period_3_end_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_3_end} ;;
    convert_tz: no
  }

  measure: period_3_len {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: number
    sql: datediff(${period_3_start},${period_3_end}) ;;
  }

  dimension: period_4_start_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_3_start} ;;
    convert_tz: no
  }

  dimension: period_4_end_display {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: date
    sql: ${period_3_end} ;;
    convert_tz: no
  }

  measure: period_4_len {
    view_label: "Timeline Comparison Fields"
    group_label: "Period Display"
    type: number
    sql: datediff(${period_4_start},${period_4_end}) ;;
  }

  dimension: period_1_start {
    label: "Period 1 Start"
    view_label: "Timeline Comparison Fields"
    description: "Calculates the start of the current period"
    type: date_raw
    hidden:  yes
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
          {% when "trailing" or "default"%}
            date_add('days', -(${size_of_range_dim}), ${current_date_dim})

          {% when "trailing_30" %}
            date_add('days', -(30), ${current_date_dim})

          {% when "trailing_90" %}
            date_add('days', -(90), ${current_date_dim})

          {% when "trailing_180" %}
            date_add('days', -(180), ${current_date_dim})

           {% when "trailing_365" %}
            date_add('days', -(365), ${current_date_dim})

          {% when "mtd_vs_prior_month" or "mtd_vs_prior_quarter" or "mtd_vs_prior_year" %}
            date_trunc('month', ${current_date_dim})

          {% when "qtd_vs_prior_quarter" or "qtd_vs_prior_year"%}
            date_trunc('quarter', ${current_date_dim})

          {% when "ytd_vs_prior_year" %}
            date_trunc('year', ${current_date_dim})

          {% when "last_month_vs_two_months_ago" %}
            date_trunc('month', dateadd('months', -1, ${current_date_dim}))

          {% when "last_quarter_vs_two_quarters_ago" %}
            date_trunc('quarter', dateadd('quarter', -1, ${current_date_dim}))

          {% when "last_year_vs_two_years_ago" %}
            date_trunc('year', dateadd('year', -1, ${current_date_dim}))

        {% endcase %}) --Note here ;;
  }

  dimension: period_1_end {
    label: "Period 1 End"
    view_label: "Timeline Comparison Fields"
    description: "Calculates the end of the current period"
    type: date_raw
    hidden:  yes
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
          {% when "trailing" or "default" or "trailing_30"  or "trailing_90" or "trailing_365" or "trailing_180" or "yoy" or "mtd_vs_prior_month" or "mtd_vs_prior_quarter" or "mtd_vs_prior_year" or "qtd_vs_prior_quarter" or "qtd_vs_prior_year"  or "ytd_vs_prior_year"  %}
            ${current_date_dim}

          {% when "last_month_vs_two_months_ago" %}
            dateadd('days', -1 ,dateadd('months', 1, ${period_1_start}))

          {% when "last_quarter_vs_two_quarters_ago" %}
            dateadd('days', -1 ,dateadd('quarter', 1, ${period_1_start}))

          {% when "last_year_vs_two_years_ago" %}
            dateadd('days', -1 ,dateadd('year', 1, ${period_1_start}))

        {% endcase %});;
  }

  dimension: period_2_start {
    view_label: "Timeline Comparison Fields"
    description: "Calculates the start of the previous period"
    type: date_raw
    hidden:  yes
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
          {% when "trailing" or "default"  %}
            dateadd('days', -(${size_of_range_dim}+1), ${period_1_start})

          {% when "trailing_30" %}
            dateadd('days', -31, ${period_1_start})

          {% when "trailing_90" %}
            dateadd('days', -91, ${period_1_start})

          {% when "trailing_180" %}
            dateadd('days', -181, ${period_1_start})

          {% when "trailing_365" or "yoy" %}
            dateadd('days', -366, ${period_1_start})

          {% when "mtd_vs_prior_month" %}
              dateadd('days', -(datediff('days', ${period_1_start}, dateadd('months', 1, ${period_1_start}))), ${period_1_start})

          {% when "mtd_vs_prior_quarter" %}
            dateadd('days', -(datediff('days', ${period_1_start}, dateadd('quarters', 1, ${period_1_start}))), ${period_1_start})

          {% when "mtd_vs_prior_year" %}
            dateadd('days', -365, ${period_1_start})

          {% when "qtd_vs_prior_quarter" %}
            dateadd('days', -(datediff('days', ${period_1_start}, dateadd('quarters', 1, ${period_1_start}))), ${period_1_start})

          {% when "qtd_vs_prior_year" %}
            dateadd('days', -365, ${period_1_start})

          {% when "ytd_vs_prior_year" %}
            dateadd('days', -365, ${period_1_start})

          {% when "last_month_vs_two_months_ago" %}
            dateadd('days', -(datediff('days', ${period_1_start}, ${period_1_end})+1), ${period_1_start})

          {% when "last_quarter_vs_two_quarters_ago" %}
            dateadd('days', -(datediff('days', ${period_1_start}, ${period_1_end})+1), ${period_1_start})

          {% when "last_year_vs_two_years_ago" %}
            dateadd('days', -(datediff('days', ${period_1_start}, ${period_1_end})+1), ${period_1_start})

        {% endcase %});;
  }

  dimension: period_2_end {
    view_label: "Timeline Comparison Fields"
    description: "Calculates the end of the previous period"
    type: date_raw
    hidden:  yes
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
            {% when "trailing" or "default" or "trailing_30" or "trailing_90" or "trailing_180" or "trailing_365" %}
              dateadd('days', -1, ${period_1_start})
            {% when "mtd_vs_prior_month" or "mtd_vs_prior_quarter" or "mtd_vs_prior_year" or "qtd_vs_prior_quarter" or "qtd_vs_prior_year" or "ytd_vs_prior_year" %}
              dateadd('days', (datediff('days', ${period_1_start}, ${period_1_end})), ${period_2_start})

            {% when "last_month_vs_two_months_ago" %}
              dateadd('days', -(datediff('days', ${period_1_start}, ${period_1_end})+1), ${period_1_end})

            {% when "last_quarter_vs_two_quarters_ago" %}
              dateadd('days', -(datediff('days', ${period_1_start}, ${period_1_end})+1), ${period_1_end})

            {% when "last_year_vs_two_years_ago" %}
              dateadd('days', -(datediff('days', ${period_1_start}, ${period_1_end})+1), ${period_1_end})

          {% endcase %});;




            # {% when "trailing_30" %}
            #   dateadd('days', -30, ${period_1_end})

            # {% when "trailing_90" %}
            #   dateadd('days', -90, ${period_1_end})

            # {% when "trailing_180" %}
            #   dateadd('days', -180, ${period_1_end})

            # {% when "trailing_365" or "yoy" %}
            #   dateadd('days', -365, ${period_1_end})
  }

  dimension: period_3_start {
    view_label: "Timeline Comparison Fields"
    description: "Calculates the start of 2 periods ago"
    type: date_raw
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
          {% when "trailing" or "default"  %}
            dateadd('days', -(${size_of_range_dim}), ${period_2_start})

          {% when "trailing_30" %}
            dateadd('days', -30, ${period_2_start})

          {% when "trailing_90" %}
            dateadd('days', -90, ${period_2_start})

          {% when "trailing_180" %}
            dateadd('days', -180, ${period_2_start})

          {% when "trailing_365" or "yoy" %}
            dateadd('days', -365, ${period_2_start})

          {% when "mtd_vs_prior_month" %}
              dateadd('days', -(datediff('days', ${period_2_start}, dateadd('months', 1, ${period_2_start}))), ${period_2_start})

          {% when "mtd_vs_prior_quarter" %}
            dateadd('days', -(datediff('days', ${period_2_start}, dateadd('quarters', 1, ${period_2_start}))), ${period_2_start})

          {% when "mtd_vs_prior_year" %}
            dateadd('days', -365, ${period_2_start})

          {% when "qtd_vs_prior_quarter" %}
            dateadd('days', -(datediff('days', ${period_2_start}, dateadd('quarters', 1, ${period_2_start}))), ${period_2_start})

          {% when "qtd_vs_prior_year" %}
            dateadd('days', -365, ${period_2_start})

          {% when "ytd_vs_prior_year" %}
            dateadd('days', -365, ${period_2_start})

          {% when "last_month_vs_two_months_ago" %}
            dateadd('days', -(datediff('days', ${period_2_start}, ${period_2_end})+1), ${period_2_start})

          {% when "last_quarter_vs_two_quarters_ago" %}
            dateadd('days', -(datediff('days', ${period_2_start}, ${period_2_end})+1), ${period_2_start})

          {% when "last_year_vs_two_years_ago" %}
            dateadd('days', -(datediff('days', ${period_2_start}, ${period_2_end})+1), ${period_2_start})

        {% endcase %});;
    hidden: yes

  }

  dimension: period_3_end {
    view_label: "Timeline Comparison Fields"
    description: "Calculates the end of 2 periods ago"
    type: date_raw
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
            {% when "trailing" or "default" %}
              dateadd('days', -1, ${period_2_start})

            {% when "trailing_30" %}
              dateadd('days', -30, ${period_2_end})

            {% when "trailing_90" %}
              dateadd('days', -90, ${period_2_end})

            {% when "trailing_180" %}
              dateadd('days', -180, ${period_2_end})

            {% when "trailing_365" or "yoy" %}
              dateadd('days', -365, ${period_2_end})

            {% when "mtd_vs_prior_month" or "mtd_vs_prior_quarter" or "mtd_vs_prior_year" or "qtd_vs_prior_quarter" or "qtd_vs_prior_year" or "ytd_vs_prior_year" %}
              dateadd('days', (datediff('days', ${period_2_start}, ${period_2_end})), ${period_3_start})

            {% when "last_month_vs_two_months_ago" %}
              dateadd('days', -(datediff('days', ${period_2_start}, ${period_2_end})+1), ${period_2_end})

            {% when "last_quarter_vs_two_quarters_ago" %}
              dateadd('days', -(datediff('days', ${period_2_start}, ${period_2_end})+1), ${period_2_end})

            {% when "last_year_vs_two_years_ago" %}
              dateadd('days', -(datediff('days', ${period_2_start}, ${period_2_end})+1), ${period_2_end})

          {% endcase %});;
    hidden: yes
  }

  dimension: period_4_start {
    view_label: "Timeline Comparison Fields"
    description: "Calculates the start of 4 periods ago"
    type: date_raw
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
          {% when "trailing" or "default"  %}
            dateadd('days', -(${size_of_range_dim}), ${period_3_start})

          {% when "trailing_30" %}
            dateadd('days', -30, ${period_3_start})

          {% when "trailing_90" %}
            dateadd('days', -90, ${period_3_start})

          {% when "trailing_180" %}
            dateadd('days', -180, ${period_3_start})

          {% when "trailing_365" or "yoy" %}
            dateadd('days', -365, ${period_3_start})

          {% when "mtd_vs_prior_month" %}
              dateadd('days', -(datediff('days', ${period_3_start}, dateadd('months', 1, ${period_3_start}))), ${period_3_start})

          {% when "mtd_vs_prior_quarter" %}
            dateadd('days', -(datediff('days', ${period_3_start}, dateadd('quarters', 1, ${period_3_start}))), ${period_3_start})

          {% when "mtd_vs_prior_year" %}
            dateadd('days', -365, ${period_3_start})

          {% when "qtd_vs_prior_quarter" %}
            dateadd('days', -(datediff('days', ${period_3_start}, dateadd('quarters', 1, ${period_3_start}))), ${period_3_start})

          {% when "qtd_vs_prior_year" %}
            dateadd('days', -365, ${period_3_start})

          {% when "ytd_vs_prior_year" %}
            dateadd('days', -365, ${period_3_start})

          {% when "last_month_vs_two_months_ago" %}
            dateadd('days', -(datediff('days', ${period_3_start}, ${period_3_end})+1), ${period_3_start})

          {% when "last_quarter_vs_two_quarters_ago" %}
            dateadd('days', -(datediff('days', ${period_3_start}, ${period_3_end})+1), ${period_3_start})

          {% when "last_year_vs_two_years_ago" %}
            dateadd('days', -(datediff('days', ${period_3_start}, ${period_3_end})+1), ${period_3_start})

        {% endcase %});;
    hidden: yes
  }

  dimension: period_4_end {
    view_label: "Timeline Comparison Fields"
    description: "Calculates the end of 4 periods ago"
    type: date_raw
    sql:
    {% if user_compare_to._parameter_value != "none" %}
        {% assign comp_value = user_compare_to._parameter_value  %}
    {% else  %}
        {% assign comp_value = compare_to._parameter_value  %}
    {% endif %}

    date({% case comp_value %}
            {% when "trailing" or "default" %}
              dateadd('days', -1, ${period_3_start})

            {% when "trailing_30" %}
              dateadd('days', -30, ${period_3_end})

            {% when "trailing_90" %}
              dateadd('days', -90, ${period_3_end})

            {% when "trailing_180" %}
              dateadd('days', -180, ${period_3_end})

            {% when "trailing_365" or "yoy" %}
              dateadd('days', -365, ${period_3_end})

            {% when "mtd_vs_prior_month" or "mtd_vs_prior_quarter" or "mtd_vs_prior_year" or "qtd_vs_prior_quarter" or "qtd_vs_prior_year" or "ytd_vs_prior_year" %}
              dateadd('days', (datediff('days', ${period_3_start}, ${period_3_end})), ${period_4_start})

            {% when "last_month_vs_two_months_ago" %}
              dateadd('days', -(datediff('days', ${period_3_start}, ${period_3_end})+1), ${period_3_end})

            {% when "last_quarter_vs_two_quarters_ago" %}
              dateadd('days', -(datediff('days', ${period_3_start}, ${period_3_end})+1), ${period_3_end})

            {% when "last_year_vs_two_years_ago" %}
              dateadd('days', -(datediff('days', ${period_3_start}, ${period_3_end})+1), ${period_3_end})

          {% endcase %});;
    hidden: yes
  }

  parameter: as_of_date {
    label: "As of Date"
    description: "Use this to change the value of the current date. Setting to a date will change the tile/dashboard to act as if today is the selected date."
    type: date
    group_label: "Dashboard User Selection"
    view_label: "Timeline Comparison Fields"
  }



  parameter: size_of_range {
    description: "How many days in your period (trailng only)?"
    label: "Number of Trailing Days"
    group_label: "Tile Only"
    type: unquoted
    default_value: "0"
    view_label: "Timeline Comparison Fields"
  }

  parameter: user_size_of_range {
    description: "How many days in your period (trailng only)?"
    label: "Number of Trailing Days"
    group_label: "Dashboard User Selection"
    type: unquoted
    default_value: "0"
    view_label: "Timeline Comparison Fields"
  }

  parameter: exclude_days {
    description: "Select days to exclude"
    label: "Exclude Days:"
    group_label: "Tile Only"
    view_label: "Timeline Comparison Fields"
    type: unquoted
    allowed_value: {
      label: "No Exclude"
      value: "0"
    }
    allowed_value: {
      label: "Exclude Current Day"
      value: "1"
    }
    allowed_value: {
      label: "Exclude Yesterday"
      value: "2"
    }
    allowed_value: {
      label: "Last Data"
      value: "999"
    }
    allowed_value: {
      label: "End of Last Full Week"
      value: "start_of_week"
    }
    allowed_value: {
      label: "Start of Month"
      value: "start_of_month"
    }
    allowed_value: {
      label: "Start of Quarter"
      value: "start_of_quarter"
    }
    allowed_value: {
      label: "Start of Year"
      value: "start_of_year"
    }

    default_value: "0"
  }


  parameter: compare_to {
    label: "Compare to"
    view_label: "Timeline Comparison Fields"
    group_label: "Tile Only"
    type: unquoted
    allowed_value: {
      label: "Select a Timeframe"
      value: "none"
    }
    allowed_value: {
      label: "Trailing"
      value: "trailing"
    }
    allowed_value: {
      label: "Trailing 30 Days"
      value: "trailing_30"
    }
    allowed_value: {
      label: "Trailing 90 Days"
      value: "trailing_90"
    }
    allowed_value: {
      label: "Trailing 180 Days"
      value: "trailing_180"
    }
    allowed_value: {
      label: "Trailing 365 Days"
      value: "trailing_365"
    }
    allowed_value: {
      label: "MTD vs Prior Month"
      value: "mtd_vs_prior_month"
    }
    allowed_value: {
      label: "MTD vs Prior Quarter"
      value: "mtd_vs_prior_quarter"
    }
    allowed_value: {
      label: "MTD vs Prior Year"
      value: "mtd_vs_prior_year"
    }
    allowed_value: {
      label: "QTD vs Prior Quarter"
      value: "qtd_vs_prior_quarter"
    }
    allowed_value: {
      label: "QTD vs Prior Year"
      value: "qtd_vs_prior_year"
    }
    allowed_value: {
      label: "YTD vs Prior Year"
      value: "ytd_vs_prior_year"
    }
    allowed_value: {
      label: "Last Month Vs Two Months Ago"
      value: "last_month_vs_two_months_ago"
    }
    allowed_value: {
      label: "Last Quarter Vs Two Quarters Ago"
      value: "last_quarter_vs_two_quarters_ago"
    }
    allowed_value: {
      label: "Last Year vs Two Years Ago"
      value: "last_year_vs_two_years_ago"
    }
    default_value: "none"
  }


  parameter: user_compare_to {
    label: "PoP Selection"
    view_label: "Timeline Comparison Fields"
    group_label: "Dashboard User Selection"
    type: unquoted
    allowed_value: {
      label: "Select a Timeframe"
      value: "none"
    }
    allowed_value: {
      label: "Trailing"
      value: "trailing"
    }
    allowed_value: {
      label: "Trailing 30 Days"
      value: "trailing_30"
    }
    allowed_value: {
      label: "Trailing 90 Days"
      value: "trailing_90"
    }
    allowed_value: {
      label: "Trailing 180 Days"
      value: "trailing_180"
    }
    allowed_value: {
      label: "Trailing 365 Days"
      value: "trailing_365"
    }
    allowed_value: {
      label: "MTD vs Prior Month"
      value: "mtd_vs_prior_month"
    }
    allowed_value: {
      label: "MTD vs Prior Quarter"
      value: "mtd_vs_prior_quarter"
    }
    allowed_value: {
      label: "MTD vs Prior Year"
      value: "mtd_vs_prior_year"
    }
    allowed_value: {
      label: "QTD vs Prior Quarter"
      value: "qtd_vs_prior_quarter"
    }
    allowed_value: {
      label: "QTD vs Prior Year"
      value: "qtd_vs_prior_year"
    }
    allowed_value: {
      label: "YTD vs Prior Year"
      value: "ytd_vs_prior_year"
    }
    allowed_value: {
      label: "Last Month Vs Two Months Ago"
      value: "last_month_vs_two_months_ago"
    }
    allowed_value: {
      label: "Last Quarter Vs Two Quarters Ago"
      value: "last_quarter_vs_two_quarters_ago"
    }
    allowed_value: {
      label: "Last Year vs Two Years Ago"
      value: "last_year_vs_two_years_ago"
    }
    default_value: "none"
  }

  parameter: comparison_periods {
    label: "Number of Periods"
    group_label: "Tile Only"
    view_label: "Timeline Comparison Fields"
    description: "Choose the number of periods you would like to compare - defaults to 2. Only works with templated periods from step 2."
    type: number
    allowed_value: {
      label: "Select"
      value: "none"
    }
    allowed_value: {
      label: "2"
      value: "2"
    }
    allowed_value: {
      label: "3"
      value: "3"
    }
    allowed_value: {
      label: "4"
      value: "4"
    }
    default_value: "none"
  }


  dimension: size_of_range_dim {
    view_label: "size_of_range_dim"
    hidden: yes
    sql:
      {% if user_size_of_range._parameter_value != "0" %}
        {% assign comp_value = user_size_of_range._parameter_value  %}
    {% else  %}
        {% assign comp_value = size_of_range._parameter_value  %}
    {% endif %}
    {{ comp_value}} ;;
    type: number
  }

  dimension: comparison_periods_dim {
    view_label: "comparison_periods_dim"
    hidden: yes
    sql: {% parameter comparison_periods %} ;;
    type: number
  }

  dimension: exclude_days_dim {
    view_label: "exclude_days_dim"
    hidden: yes
    sql: {% parameter exclude_days %} ;;
    type: number
  }


  dimension: period {
    view_label: "Timeline Comparison Fields"
    label: "Period Pivot"
    group_label: "Pivot Dimensions"
    description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period', 'Previous Period' or 'Last Year', '2 Years Ago'"
    type: string
    order_by_field: order_for_period
    # These were added to the end of each period, but this caused a bug in Looker. Because the series name changed each night the system ended up
    # falling back to the default colors.
    # || ' (' || ${period_1_start} || ' to ' ||  ${period_1_end} || ')'
    # || ' (' || ${period_2_start} || ' to ' ||  ${period_2_end} || ')'
    # || ' (' || ${period_3_start} || ' to ' ||  ${period_3_end} || ')'
    # || ' (' || ${period_4_start} || ' to ' ||  ${period_4_end} || ')'
    sql:   case
             when ${event_date} between ${period_1_start} and ${period_1_end} then
                {% if user_compare_to._parameter_value != "none" %}
                    {% assign comp_value = user_compare_to._parameter_value  %}
                {% else  %}
                    {% assign comp_value = compare_to._parameter_value  %}
                {% endif %}
              {% case comp_value %}
                {% when "trailing" or "default" or "trailing_30" or "trailing_90" or "trailing_180" or "trailing_365" or "yoy" %}
                  'This Period'

                {% when "mtd_vs_prior_month" or "mtd_vs_prior_quarter" or "mtd_vs_prior_year"  %}
                  'This Month'

                {% when "qtd_vs_prior_quarter" or "qtd_vs_prior_year" %}
                  'This Quarter'

                {% when "ytd_vs_prior_year" %}
                  'This Year'

                {% when "last_month_vs_two_months_ago" %}
                  'Last Month'

                {% when "last_quarter_vs_two_quarters_ago" %}
                  'Last Quarter'

                {% when "last_year_vs_two_years_ago" %}
                  'Last Year'
              {% endcase %}


             when ${event_date} between ${period_2_start} and ${period_2_end} then
            {% if user_compare_to._parameter_value != "none" %}
                {% assign comp_value = user_compare_to._parameter_value  %}
            {% else  %}
                {% assign comp_value = compare_to._parameter_value  %}
            {% endif %}
              {% case comp_value %}
                {% when "trailing" or "default" %}
                  'Prior Period'
                {% when "trailing_30" %}
                  'Period Last Month'

                {% when "trailing_90" %}
                  'Period Last Quarter'

                {% when "trailing_365" or "yoy" %}
                  'Period Prior Year'

                {% when "mtd_vs_prior_month" %}
                  'Prior Month'

                {% when "qtd_vs_prior_quarter"%}
                  'Prior Quarter'

                {% when "qtd_vs_prior_year" %}
                  'Same Quarter Prior Year'

                {% when "mtd_vs_prior_quarter" %}
                   'Same Month # Prior Quarter'

                {% when "ytd_vs_prior_year" or "mtd_vs_prior_year" %}
                  'Prior Year'

                {% when "last_month_vs_two_months_ago" %}
                  'Two Months Ago'

                {% when "last_quarter_vs_two_quarters_ago" %}
                  'Two Quarters Ago'

                {% when "last_year_vs_two_years_ago" %}
                  'Two Years Ago'

              {% endcase %}

          {% if comparison_periods._parameter_value == "4" or comparison_periods._parameter_value == "3"%}
            when ${event_date} between ${period_3_start} and ${period_3_end} then
            {% if user_compare_to._parameter_value != "none" %}
                {% assign comp_value = user_compare_to._parameter_value  %}
            {% else  %}
                {% assign comp_value = compare_to._parameter_value  %}
            {% endif %}
              {% case comp_value %}
                {% when "trailing" or "default" %}
                  '2 Periods Ago'
                {% when "trailing_30" %}
                  'Period 2 Months Ago'

                {% when "trailing_90" %}
                  'Period 2 Quarters Ago'

                {% when "trailing_365" or "yoy" %}
                  'Period 2 Years Ago'

                {% when "mtd_vs_prior_month" %}
                  '2 Months Ago'

                {% when "qtd_vs_prior_quarter"%}
                  '2 Quarters Ago'

                {% when "qtd_vs_prior_year" %}
                  'Same Quarter 2 Years Ago Year'

                {% when "mtd_vs_prior_quarter" %}
                   'Same Month 2 Quarters Ago'

                {% when "ytd_vs_prior_year" or "mtd_vs_prior_year" %}
                  '3 Years Ago'

                {% when "last_month_vs_two_months_ago" %}
                  'Three Months Ago'

                {% when "last_quarter_vs_two_quarters_ago" %}
                  'Three Quarters Ago'

                {% when "last_year_vs_two_years_ago" %}
                  'Three Years Ago'
              {% endcase %}

          {% endif %}
          {% if comparison_periods._parameter_value == "4" %}
            when ${event_date} between ${period_4_start} and ${period_4_end} then
              {% if user_compare_to._parameter_value != "none" %}
                {% assign comp_value = user_compare_to._parameter_value  %}
            {% else  %}
                {% assign comp_value = compare_to._parameter_value  %}
            {% endif %}
              {% case comp_value %}
                  {% when "trailing" or "default" %}
                    '3 Periods Ago'
                  {% when "trailing_30" %}
                    'Period 3 Months Ago'

                  {% when "trailing_90" %}
                    'Period 3 Quarters Ago'

                  {% when "trailing_365" or "yoy" %}
                    'Period 3 Years Ago'

                  {% when "mtd_vs_prior_month" %}
                    '3 Months Ago'

                  {% when "qtd_vs_prior_quarter"%}
                    '3 Quarters Ago'

                  {% when "qtd_vs_prior_year" %}
                    'Same Quarter 3 Years Ago Year'

                  {% when "mtd_vs_prior_quarter" %}
                     'Same Month 3 Quarters Ago'

                  {% when "ytd_vs_prior_year" or "mtd_vs_prior_year" %}
                    '3 Years Ago'

                  {% when "last_month_vs_two_months_ago" %}
                    '4 Months Ago'

                  {% when "last_quarter_vs_two_quarters_ago" %}
                    '4 Quarters Ago'

                  {% when "last_year_vs_two_years_ago" %}
                    '4 Years Ago'
                {% endcase %}

            {% endif %}
           end ;;
  }



  # Someday - How to make date math using Liquid. https://stackoverflow.com/questions/21056965/date-math-manipulation-in-liquid-template-filter
  # Could use this to fill in the dates on the period labels!
  # dimension: period_with_dates {
  #   view_label: "Timeline Comparison Fields"
  #   label: "Period Pivot With Dates"
  #   group_label: "Pivot Dimensions"
  #   description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period', 'Previous Period' or '3 Periods Ago'"
  #   type: string
  #   order_by_field: order_for_period
  #   sql:   case
  #           when ${event_date} between ${period_1_start} and ${period_1_end}
  #           then {% if parameter compare_to == 'YoY' %}'This Year'{% else %}'This Period'{% endif %}
  #           when ${event_date} between ${period_2_start} and ${period_2_end}
  #           then {% if parameter compare_to == 'YoY' %}'This Period Last Year'{% else %}'Last Period'{% endif %}
  #           {% if comparison_periods._parameter_value == "3" or comparison_periods._parameter_value == "4" %}
  #           when ${event_date} between ${period_3_start} and ${period_3_end}
  #           then {% if parameter compare_to == 'YoY' %}'This Period 2 Years Ago'{% else %}'2 Periods Ago'{% endif %}
  #           {% endif %}
  #           {% if comparison_periods._parameter_value == "4" %}
  #           when ${event_date} between ${period_4_start} and ${period_4_end}
  #           then {% if parameter compare_to == 'YoY' %}'This Period 3 Years'{% else %}'2 Periods Ago'{% endif %}
  #           {% endif %}
  #         end ;;
  # }


  dimension: order_for_period {
    hidden: yes
    view_label: "Timeline Comparison Fields"
    label: "Period"
    description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period', 'Previous Period' or '3 Periods Ago'"
    type: string
    sql:   case
             when ${event_date} between ${period_1_start} and ${period_1_end} then 1
             when ${event_date} between ${period_2_start} and ${period_2_end} then 2
             {% if comparison_periods._parameter_value == "3" or comparison_periods._parameter_value == "4" %}
             when ${event_date} between ${period_3_start} and ${period_3_end} then 3
             {% endif %}
             {% if comparison_periods._parameter_value == "4" %}
             when ${event_date} between ${period_4_start} and ${period_4_end} then 4
             {% endif %}
           end ;;
  }

  # dimension: date_in_period {
  #   description: "Use this as your date dimension when comparing periods. Aligns the all previous periods onto the current period"
  #   label: "Date in Period"
  #   group_label: "X Axis Dimensions"
  #   type: date
  #   sql: dateadd('day', ${day_in_period}, ${period_1_start}) ;;
  #   view_label: "Timeline Comparison Fields"
  #   convert_tz: no
  # }

  dimension_group: date_in_period {
    description: "Use this as your date dimension when comparing periods. Aligns the all previous periods onto the current period"
    label: "Date in Period"
    group_label: "X Axis Dimensions"
    type: time
    timeframes: [date, quarter, year, month, week, day_of_week,fiscal_month_num, fiscal_quarter, quarter_of_year]
    sql: dateadd('day', ${day_in_period}, ${period_1_start}) ;;
    view_label: "Timeline Comparison Fields"
    convert_tz: no
  }

  dimension: date_last_period {
    description: "This can be added as a hidden column to display the value of the date 2 periods ago. Only works for 2 periods ago."
    label: "Date Last Period"
    group_label: "Period Display"
    type: date
    sql: dateadd('day', ${day_in_period}, ${period_2_start}) ;;
    view_label: "Timeline Comparison Fields"
    convert_tz: no
  }

  dimension: date_3_period {
    description: "This can be added as a hidden column to display the value of the date 2 periods ago. Only works for 3 periods ago."
    label: "Date 3 Periods Ago"
    group_label: "Period Display"
    type: date
    sql: dateadd('day', ${day_in_period}, ${period_3_start}) ;;
    view_label: "Timeline Comparison Fields"
    convert_tz: no
  }


  dimension: day_in_period {
    view_label: "Timeline Comparison Fields"
    group_label: "X Axis Dimensions"
    description: "Gives the number of days since the start of each periods. Use this to align the event dates onto the same axis, the axes will read 1,2,3, etc."
    type: number
    sql:case
                      when ${event_date} between ${period_1_start} and ${period_1_end}
                      then datediff('day', ${period_1_start}, ${event_date})
                      when ${event_date} between ${period_2_start} and ${period_2_end}
                      then datediff('day', ${period_2_start}, ${event_date})
                      {% if comparison_periods._parameter_value == "3" or comparison_periods._parameter_value == "4" %}
                      when ${event_date} between ${period_3_start} and ${period_3_end}
                      then datediff('day', ${period_3_start}, ${event_date})
                      {% endif %}
                      {% if comparison_periods._parameter_value == "4" %}
                      when ${event_date} between ${period_4_start} and ${period_4_end}
                      then datediff('day', ${period_4_start}, ${event_date})
                      {% endif %}
                    end ;;
    hidden: no
  }
}
