module SummariesHelper
  include SubmissionsHelper
  def get_summaries_table_info(assignment, groupings, render_bonus_deductions_column)
    groupings.map do |grouping|
      result = grouping.current_result
      final_due_date = assignment.submission_rule.get_collection_time(grouping.inviter.section)
      g = grouping.attributes
      g[:class_name] = get_tr_class(grouping, assignment)
      g[:name] = grouping.get_group_name
      g[:name_url] = get_grouping_name_url(grouping, result)
      g[:section] = grouping.section
      g[:repo_name] = grouping.group.repository_name
      g[:repo_url] = repo_browser_assignment_submission_path(assignment,
                                                             grouping)
      g[:commit_date] = grouping.last_commit_date
      g[:late_commit] = grouping.past_due_date?
      g[:state] = grouping.marking_state(result, assignment, current_user)
      g[:grace_credits_used] = grouping.grace_period_deduction_single
      g[:final_grade] = grouping.final_grade(result)
      g[:criteria] = get_grouping_criteria(assignment, grouping)
      if render_bonus_deductions_column # send extra points only if we are rendering bonus/deductions column
        g[:total_extra_points] = grouping.total_extra_points(result)
      end
      g[:tas] = grouping.tas.pluck(:user_name)
      g
    end
  end

  def get_grouping_criteria(assignment, grouping)
    # put all criteria in a hash for retrieval
    criteria_hash = Hash.new
    criteria = assignment.get_criteria(:ta)
    criteria.each do |criterion|
      key = 'criterion_' + criterion.class.to_s + '_' + criterion.id.to_s
      if grouping.has_submission?
        mark = grouping.current_result.marks.find_by(markable: criterion)
        if mark.nil? || mark.mark.nil?
          criteria_hash[key] = '-'
        else
          criteria_hash[key] = mark.mark.to_s
        end
      else
        criteria_hash[key] = '-'
      end
    end
    criteria_hash
  end
end
