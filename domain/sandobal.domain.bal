
public type Sandwich record {|
    readonly string designation;
    decimal sellPrice;
    Ingredient[] ingredients;
    [Language, string][] descriptions;
|};

public type Ingredient record {|
    readonly string designation;
|};

public enum Language {
    en = "en-EN",
    pt = "pt-PT",
    es = "es-ES",
    fr = "fr-FR",
    jp = "jp-JP"
}
