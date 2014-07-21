# encoding: UTF-8
# Comment controller.

class CommentsController < ApplicationController
  respond_to :html, :json

  before_filter :authenticate_user!, :except => [:create]
  load_and_authorize_resource :except => [:create]

  def create
    CommentWorker.perform_async(current_user, params)
    render nothing: true
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
    respond_with @comment
  end

  def destroy
    @post = Post.find_by_url(params[:post_id])
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to blog_post_path(@post.blog, @post)
  end
end
