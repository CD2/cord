class CommentsApi < ApplicationApi
  driver Comment

  belongs_to :article
end
