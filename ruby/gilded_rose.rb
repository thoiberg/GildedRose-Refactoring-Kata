class GildedRose
  attr_reader :items

  def initialize(items)
    @items = items
  end

  def update_quality
    pricing_engine = PricingEngine.new

    new_items = @items.map do |item|
      pricing_engine.apply(item: item)
    end

    @items = new_items
  end

  def old_update_quality
    @items.each do |item|
      if item.name != "Aged Brie" and item.name != "Backstage passes to a TAFKAL80ETC concert"
        if item.quality > 0
          if item.name != "Sulfuras, Hand of Ragnaros"
            item.quality = item.quality - 1
          end
        end
      else
        if item.quality < 50
          item.quality = item.quality + 1
          if item.name == "Backstage passes to a TAFKAL80ETC concert"
            if item.sell_in < 11
              if item.quality < 50
                item.quality = item.quality + 1
              end
            end
            if item.sell_in < 6
              if item.quality < 50
                item.quality = item.quality + 1
              end
            end
          end
        end
      end
      if item.name != "Sulfuras, Hand of Ragnaros"
        item.sell_in = item.sell_in - 1
      end
      if item.sell_in < 0
        if item.name != "Aged Brie"
          if item.name != "Backstage passes to a TAFKAL80ETC concert"
            if item.quality > 0
              if item.name != "Sulfuras, Hand of Ragnaros"
                item.quality = item.quality - 1
              end
            end
          else
            item.quality = item.quality - item.quality
          end
        else
          if item.quality < 50
            item.quality = item.quality + 1
          end
        end
      end
    end
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end

class PricingRule
  MIN_QUALITY = 0
  MAX_QUALITY = 50

  def initialize(item:)
    @item = item
  end

  def apply
    raise StandardError.new "apply method not implemented"
  end
end

class GeneralItemPricingRule < PricingRule
  def apply
    new_sell_in = @item.sell_in - 1
    new_quality = [@item.quality - quality_modifier, MIN_QUALITY].max

    Item.new(@item.name, new_sell_in, new_quality)
  end

  private

  def quality_modifier
    @item.sell_in < 0 ? 2 : 1
  end
end

class BriePricingRule < PricingRule
  def apply
    new_sell_in = @item.sell_in - 1
    new_quality = [@item.quality + 1, MAX_QUALITY].min

    Item.new(@item.name, new_sell_in, new_quality)
  end
end

class SulfurasPricingRule < PricingRule
  def apply
    @item.dup
  end
end

class BackstagePassPricingRule < PricingRule
  def apply
    new_sell_in = @item.sell_in - 1

    Item.new(@item.name, new_sell_in, new_quality)
  end

  private

  def new_quality
    quality = case @item.sell_in
              when (11..)
                @item.quality + 1
              when 6..10
                @item.quality + 2
              when 1..5
                @item.quality + 3
              when (..0)
                0
              end

    [quality, MAX_QUALITY].min
  end
end

class PricingEngine
  DEFAULT_PRICING_RULE = ::GeneralItemPricingRule
  PRICING_RULES = {
    "Aged Brie" => ::BriePricingRule,
    "Sulfuras, Hand of Ragnaros" => ::SulfurasPricingRule,
    "Backstage passes to a TAFKAL80ETC concert" => ::BackstagePassPricingRule
  }

  def apply(item:)
    pricing_rule_klass = find_for(item)
    pricing_rule = pricing_rule_klass.new(item: item)

    pricing_rule.apply
  end

  private

  def find_for(item)
    pricing_rule = PRICING_RULES[item.name] || DEFAULT_PRICING_RULE
  end
end
