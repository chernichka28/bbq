class CommentPolicy < ApplicationPolicy

  def destroy?
    can_user_destroy?
  end
end
