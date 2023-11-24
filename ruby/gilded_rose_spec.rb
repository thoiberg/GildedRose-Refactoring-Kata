require File.join(File.dirname(__FILE__), 'gilded_rose')

describe GildedRose do
  describe "#update_quality" do
    let(:brie) { "Aged Brie" }
    let(:sulfuras) { "Sulfuras, Hand of Ragnaros" }
    let(:backstage_pass) { "Backstage passes to a TAFKAL80ETC concert" }

    it "does not change the name" do
      items = [Item.new("foo", 0, 0)]
      GildedRose.new(items).update_quality
      expect(items[0].name).to eq "foo"
    end

    it "never drops quality below 0" do
      items = [Item.new("foo", 0, 0)]
      GildedRose.new(items).update_quality
      expect(items[0].quality).to eq 0
    end

    context "Miscellaneous Items" do
      it "reduces quality" do
        items = [Item.new("foo", 3, 4)]
        GildedRose.new(items).update_quality

        expect(items[0].quality).to eq 3
      end

      it "reduces sell in date" do
        items = [Item.new("foo", 4, 5)]
        GildedRose.new(items).update_quality

        expect(items[0].sell_in).to eq 3
      end

      context "when the sell in date has passed" do
        it "reduces quality twice as fast" do
          items = [Item.new("foo", -1, 3)]
          GildedRose.new(items).update_quality
  
          expect(items[0].quality).to eq 1 
        end
      end
    end

    context "Aged Brie" do
      it "increase quality as it ages" do
        items = [Item.new(brie, 2, 3)]
        GildedRose.new(items).update_quality

        expect(items[0].sell_in).to eq 1
        expect(items[0].quality).to eq 4
      end

      it "limits the maximum quality to 50" do
        items = [Item.new(brie, 2, 50)]
        GildedRose.new(items).update_quality

        expect(items[0].quality).to eq 50
      end
    end

    context "Sulfuras" do
      it "does not decrease in quality" do
        items = [Item.new(sulfuras, 10, 20)]
        GildedRose.new(items).update_quality

        expect(items[0].quality).to eq 20
      end

      it "does not decrease in sell in date" do
        items = [Item.new(sulfuras, 10, 10)]
        GildedRose.new(items).update_quality

        expect(items[0].quality).to eq 10
      end
    end

    context "Backstage passes" do
      context "when there are more than 10 days" do
        it "increases in quality at a normal rate" do
          items = [Item.new(backstage_pass, 11, 15)]
          GildedRose.new(items).update_quality

          expect(items[0].sell_in).to eq 10
          expect(items[0].quality).to eq 16
        end
      end
      
      context "when there are 10 days or less but more than 5" do
        it "increase in quality twice as fast" do
          items = [Item.new(backstage_pass, 10, 15)]
          GildedRose.new(items).update_quality

          expect(items[0].quality).to eq 17
        end
      end

      context "when there are 5 days or less" do
        it "increases in quality three times as fast" do
          items = [Item.new(backstage_pass, 5, 15)]
          GildedRose.new(items).update_quality

          expect(items[0].quality).to eq 18
        end
      end

      context "when the sell in date has passed" do
        it "the quality drops to 0" do
          items = [Item.new(backstage_pass, 0, 15)]
          GildedRose.new(items).update_quality

          expect(items[0].quality).to eq 0
        end
      end
    end
  end
end
