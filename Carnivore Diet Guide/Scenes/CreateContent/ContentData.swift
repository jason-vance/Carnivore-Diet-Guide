//
//  ContentData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation

struct ContentData: Hashable {
    
    public let id: UUID
    public let userId: String
    public let title: String
    public let markdownContent: String
    public let imageUrls: [URL]
    
    public static let sample: ContentData = .init(
        id: UUID(),
        userId: UserData.sample.id,
        title: "Assessing Personal Health and Dietary Needs",
        markdownContent: """
# Assessing Personal Health and Dietary Needs in Regards to the Carnivore Diet

## Introduction
In recent years, the carnivore diet, a regimen that involves consuming primarily animal products, has gained popularity. This diet, often seen as an extreme form of the ketogenic diet, excludes plant-based foods and focuses on meat, fish, eggs, and certain dairy products. While some individuals report improved health outcomes, the carnivore diet is a subject of debate among health professionals. This article examines the key considerations for assessing personal health and dietary needs when adopting or considering the carnivore diet.

## Understanding the Carnivore Diet
The carnivore diet is rooted in the belief that human beings thrived historically on animal-based diets. Proponents argue that this way of eating is more aligned with human evolutionary biology. Key components of the diet include:

- **Meat**: Beef, pork, lamb, and other red meats are staples.
- **Poultry**: Chicken, turkey, and other birds.
- **Fish**: Especially fatty fish like salmon for omega-3 fatty acids.
- **Eggs**: A source of protein and vitamins.
- **Limited Dairy**: Some versions allow for dairy like cheese and butter.

## Health Assessment Before Starting
Before embarking on such a diet, it's crucial to assess your health. This includes:

- **Medical History Review**: Understanding your genetic predisposition to certain conditions like heart disease or high cholesterol.
- **Current Health Status**: Evaluating factors such as weight, blood pressure, and overall health.
- **Blood Tests**: To establish a baseline for cholesterol, blood sugar, and nutrient levels.

## Potential Benefits
Some individuals report benefits from the carnivore diet, including:

- **Weight Loss**: Due to its high-protein content and the satiating nature of meat.
- **Improved Digestion**: Some find that eliminating plant fibers aids digestion.
- **Reduction in Inflammation**: Reported by some due to the exclusion of certain plant-based foods.

## Risks and Considerations
However, there are significant risks and concerns:

- **Nutritional Deficiencies**: Lack of vitamins and minerals found in plant-based foods.
- **Increased Risk of Heart Disease**: Due to high saturated fat and cholesterol intake.
- **Impact on Gut Health**: The absence of fiber can affect gut microbiota negatively.

## Personalizing the Diet
If considering the carnivore diet, it's essential to tailor it to individual health needs:

- **Monitor Nutrient Intake**: Ensuring adequate intake of all essential nutrients.
- **Regular Health Check-ups**: To monitor cholesterol, blood pressure, and other vital health markers.
- **Consult a Dietitian**: Professional guidance is crucial in managing risks and ensuring nutritional adequacy.

## Conclusion
The carnivore diet is a controversial and extreme dietary choice that may offer benefits for some but poses significant risks. It is vital for anyone considering this diet to conduct a thorough health assessment, understand the potential risks and benefits, and seek guidance from healthcare professionals. Personalizing the diet to one's specific health needs and regularly monitoring health indicators is crucial in mitigating risks associated with this diet. As with any dietary change, individual responses can vary widely, and what works for one person may not be suitable for another.
""",
        imageUrls: [
            URL(string: "https://plantbasednews.org/app/uploads/2023/04/plant-based-news-what-is-carnivore-diet.jpg")!,
            URL(string: "https://www.health.com/thmb/jSs3XW5otqOQmCXkwyCcS3PADCw=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/CarnivoreDiet-76e2ef4d594c47a4ad6b37d08d277f17.jpg")!,
            URL(string: "https://b2976109.smushcdn.com/2976109/wp-content/uploads/2023/09/carnivorediet.jpeg?lossy=2&strip=1&webp=1")!
        ]
    )
}
