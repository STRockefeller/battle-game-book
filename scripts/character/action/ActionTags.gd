class_name ActionTags

enum Tags{
    # 行動類型(1~90)
    Attack = 1,
    Heal = 2,
    Buff = 3,
    Debuff = 4,
    Movement = 5, # 位移類行動
    Physical = 6,
    Magical = 7,
    # 行動分類(91~100)
    Common = 91, # 寫死在程式碼裡面，所有角色都能配置的行動
    Special = 92, # 來自 tres 資源檔案，特定角色才能使用的行動
    # 攻擊相關(101~200)
    # 輔助相關(201~300)
    # 屬性特徵(301~400)
    Fire = 301,
    Water = 302,
    Earth = 303,
    Wind = 304,
    Light = 305,
    Dark = 306,
    Poison = 307,
    # 狀態效果相關(401~500)
    StanceChange = 401,
    EffectApply = 402,
}