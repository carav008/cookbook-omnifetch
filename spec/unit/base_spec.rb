require "spec_helper"
require "cookbook-omnifetch/base"

module CookbookOmnifetch
  describe BaseLocation do
    let(:constraint) { double("constraint") }
    let(:dependency) { double("dependency", name: "cookbook", version_constraint: constraint) }

    subject { described_class.new(dependency) }

    describe "#installed?" do
      it "is an abstract function" do
        expect { subject.installed? }.to raise_error(AbstractFunction)
      end
    end

    describe "#install" do
      it "is an abstract function" do
        expect { subject.install }.to raise_error(AbstractFunction)
      end
    end

    describe "#cached_cookbook" do
      it "is an abstract function" do
        expect { subject.cached_cookbook }.to raise_error(AbstractFunction)
      end
    end

    describe "#to_lock" do
      it "is an abstract function" do
        expect { subject.to_lock }.to raise_error(AbstractFunction)
      end
    end

    describe "#lock_data" do
      it "is an abstract function" do
        expect { subject.lock_data }.to raise_error(AbstractFunction)
      end
    end

    describe "#validate_cached!" do
      context "when the path is not a cookbook" do
        before { CookbookOmnifetch.stub(:cookbook?).and_return(false) }

        it "raises an error" do
          expect do
            subject.validate_cached!("/foo/bar")
          end.to raise_error(NotACookbook)
        end
      end

      context "when the path is a cookbook" do
        let(:cookbook) do
          double("cookbook",
            cookbook_name: "cookbook",
            version: "0.1.0")
        end

        before do
          CookbookOmnifetch.stub(:cookbook?).and_return(true)
          MockCachedCookbook.stub(:from_path).and_return(cookbook)
        end

        it "raises an error if the constraint does not satisfy" do
          constraint.stub(:satisfies?).with("0.1.0").and_return(false)
          expect do
            subject.validate_cached!(cookbook)
          end.to raise_error(CookbookValidationFailure)
        end

        it "raises an error if the names do not match" do
          constraint.stub(:satisfies?).with("0.1.0").and_return(true)
          cookbook.stub(:cookbook_name).and_return("different_name")
          expect do
            subject.validate_cached!(cookbook)
          end.to raise_error(MismatchedCookbookName)
        end

        it "returns true when the validation succeeds" do
          constraint.stub(:satisfies?).with("0.1.0").and_return(true)
          expect(subject.validate_cached!(cookbook)).to be true
        end
      end
    end
  end
end
