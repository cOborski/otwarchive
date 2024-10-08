require "spec_helper"

describe CommentsHelper do
  describe "#comment_link_with_commentable_name" do
    context "when ultimate parent is AdminPost" do
      let(:comment) { create(:comment, :on_admin_post) }

      it "links to comment" do
        text = "Comment on the news post #{comment.ultimate_parent.commentable_name}"
        expect(helper.comment_link_with_commentable_name(comment)).to eq(link_to(text, comment_path(comment)))
      end
    end

    context "when ultimate parent is Tag" do
      let(:comment) { create(:comment, :on_tag) }

      it "links to comment" do
        text = "Comment on the tag #{comment.ultimate_parent.commentable_name}"
        expect(helper.comment_link_with_commentable_name(comment)).to eq(link_to(text, comment_path(comment)))
      end
    end

    context "when ultimate parent is Work" do
      let(:comment) { create(:comment) }

      it "links to comment" do
        text = "Comment on the work #{comment.ultimate_parent.commentable_name}"
        expect(helper.comment_link_with_commentable_name(comment)).to eq(link_to(text, comment_path(comment)))
      end
    end

    context "when ultimate parent is unknown" do
      let(:comment) { create(:comment) }

      before do
        comment.parent.delete
        comment.reload
      end

      it "links to comment" do
        text = "Comment on unknown item"
        expect(helper.comment_link_with_commentable_name(comment)).to eq(link_to(text, comment_path(comment)))
      end
    end
  end

  describe "#commenter_id_for_css_classes" do
    context "when commenter is a user" do
      let(:user) { create(:user) }
      let(:comment) { create(:comment, pseud: user.default_pseud) }

      it "returns commenter id css class name" do
        expect(helper.commenter_id_for_css_classes(comment)).to eq("user-#{user.id}")
      end

      context "when commenter is creator of work inside anonymous collection" do
        let(:anonymous_collection) { create(:anonymous_collection) }
        let(:work) { create(:work, authors: [user.default_pseud], collections: [anonymous_collection]) }
        let(:comment) { create(:comment, pseud: user.default_pseud, commentable: work.last_posted_chapter) }
  
        it "returns nil" do
          expect(helper.commenter_id_for_css_classes(comment)).to eq(nil)
        end
      end
    end
    
    context "when commenter is a visitor" do
      let(:comment) { create(:comment, :by_guest) }

      it "returns nil" do
        expect(helper.commenter_id_for_css_classes(comment)).to eq(nil)
      end
    end

    context "when comment is deleted" do
      let(:comment) { create(:comment, is_deleted: true) }

      it "returns nil" do
        expect(helper.commenter_id_for_css_classes(comment)).to eq(nil)
      end
    end

    context "when comment is hidden by admin" do
      let(:comment) { create(:comment, hidden_by_admin: true) }

      it "returns nil" do
        expect(helper.commenter_id_for_css_classes(comment)).to eq(nil)
      end
    end
  end

  describe "#css_classes_for_comment" do
    context "when comment exists" do
      let(:user) { create(:user) }
      let(:comment) { create(:comment, pseud: user.default_pseud) }
      let(:unreviewed_comment) { create(:comment, :unreviewed, pseud: user.default_pseud) }
      
      it "has classes" do
        expect(helper.css_classes_for_comment(comment)).to eq("comment group user-#{user.id}")
      end

      it "includes unreviewed class when comment is unreviewed" do
        expect(helper.css_classes_for_comment(unreviewed_comment)).to eq("unreviewed comment group user-#{user.id}")
      end
    end

    context "when commenter is an official" do
      let(:official_user) { create(:official_user) }
      let(:comment) { create(:comment, pseud: official_user.default_pseud) }
  
      it "has official class" do
        expect(helper.css_classes_for_comment(comment)).to match("official")
      end

      context "commenter is also creator of a work inside anonymous collection" do
        let(:work) { create(:work, authors: [official_user.default_pseud], collections: [create(:anonymous_collection)]) }
        let(:comment) { create(:comment, pseud: official_user.default_pseud, commentable: work.last_posted_chapter) }
      
        it "does not have official class" do
          expect(helper.css_classes_for_comment(comment)).not_to match("official")
        end
      end 
    end
  end
end
