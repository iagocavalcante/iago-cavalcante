%{
  title: "Understanding Advanced TypeScript and Knex Integration for Clean and Efficient Database Interactions",
  author: "Iago Cavalcante",
  tags: ~w(typescript javascript),
  description: "In this article, we will discuss about typescript for database integration.",
  locale: "en",
  published: true
}
---

In this post, we'll dive deep into a TypeScript module that leverages advanced techniques to interact with a database using Knex.js, ensuring clean and efficient data handling. We will break down the code, explain the key concepts, and highlight the advantages of this approach.

#### Concepts Used

1. **TypeScript Type Definitions**:

   - We use advanced type definitions from TypeScript and the `type-fest` library to ensure our data conforms to specific shapes. This improves type safety and makes our code more predictable and less prone to errors.

2. **Zod for Schema Validation**:

   - Zod is a TypeScript-first schema declaration and validation library. It allows us to define schemas for our data models and validate them at runtime.

3. **Knex.js for Database Interactions**:

   - Knex.js is a SQL query builder for Node.js. It allows us to write SQL queries in a programmatic and type-safe way.

4. **Utility Functions for Case Conversion**:

   - Functions like `CamelToSnakeCase` and `SnakeToCamelCase` help convert object keys between camelCase and snake\_case, ensuring consistency between JavaScript objects and database records.

5. **Type Guards**:

   - Type guards, such as `isContactDto`, help us ensure that our data matches the expected types before performing operations, enhancing runtime safety.

#### Code Explanation

```typescript
import type { Knex } from 'knex';
import { CamelCase, CamelCasedProperties, SnakeCase, SnakeCasedProperties } from 'type-fest';
import { z } from 'zod';
import { knex } from '../db';

//#region Tools

type IterableGenericObject = { [k: string]: any };

function prefixObjectKeys(obj: { [k: string]: any }, prefix: string) {
    return Object.fromEntries(
        Object.entries(obj)
            .map(([k, v]) => [`${prefix}${k}`, v])
    );
}

export function CamelToSnakeCase<T extends string>(str: T): SnakeCase<T> {
    return str.toString()
        .split('')
        .map((char) => (char.toUpperCase() === char ? '_' : '') + char.toLowerCase())
        .join('') as SnakeCase<T>;
}

export function SnakeToCamelCase<T extends string>(str: T): CamelCase<T> {
    return str.toString()
        .split('')
        .map((char, i, a) => {
            if (i < 1) return char.toLowerCase();
            if (char === '_') return '';
            if (a[i - 1] === '_') return char.toUpperCase();
            return char.toLowerCase();
        })
        .join('') as CamelCase<T>;
}

export function ObjectToSnakeCasedProperties<
    I extends IterableGenericObject,
    O = SnakeCasedProperties<I>
>(obj: I, keyMap: Map<keyof I, keyof O> = new Map()) {
    return Object.fromEntries(
        Object.entries(obj)
            .map(([prop, value]) => [
                keyMap.get(prop) || CamelToSnakeCase(prop),
                value
            ] as const)
    ) as O;
}

export function ObjectToCamelCasedProperties<
    I extends IterableGenericObject,
    O = CamelCasedProperties<I>
>(obj: I, keyMap: Map<keyof I, keyof O> = new Map()) {
    return Object.fromEntries(
        Object.entries(obj)
            .map(([prop, value]) => [
                keyMap.get(prop) || SnakeToCamelCase(prop),
                value
            ] as const)
    ) as O;
}

//#endregion

//#region Contact domain

export const ContactSchema = z.object({
    id: z.number().positive().gt(0),
    firstName: z.string().min(1),
    lastName: z.string().min(1),
    phoneNumber: z.string().min(8).max(15),
});

export const ContactDtoSchema = ContactSchema.partial();
export const ContactUpsertDtoSchema = ContactSchema.omit({ id: true });

export type Contact = z.infer<typeof ContactSchema>;
export type ContactDto = z.infer<typeof ContactDtoSchema>;
export type ContactUpsertDto = z.infer<typeof ContactUpsertDtoSchema>;
export type ContactTableItem = SnakeCasedProperties<Contact>;

// Type guard example:
export function isContactDto(obj: Record<string, any>): obj is ContactDto {
    return ContactSchema.deepPartial().safeParse(obj).success;
}

export function isContactUpsertDto(obj: Record<string, any>): obj is ContactUpsertDto {
    return ContactUpsertDtoSchema.safeParse(obj).success;
}

//#endregion

//#region Contact repository

function getKnexInstance(knexInstance = knex) {
    return (knexInstance as Knex<ContactTableItem, ContactTableItem[]>)(`contacts`);
}

export const ContactFields = Object.freeze(Object.values(ContactSchema.keyof().Values));

export async function queryContact(contactWhere: ContactDto, fields = ContactFields, txn?: typeof knex): Promise<Contact | null> {
    if (!isContactDto(contactWhere)) {
        throw new Error('Invalid contact given');
    }

    const qb = fields.reduce((queryBuilder, col) => {
        return queryBuilder.select(`c.${col}`);
    }, getKnexInstance(txn));

    const where = prefixObjectKeys(ObjectToSnakeCasedProperties<ContactDto>(contactWhere), 'c.');

    const results = await qb
        .from<ContactTableItem, ContactTableItem[]>({ c: 'contacts' })
        .where(where);

    const [firstContactRow] = results;

    return firstContactRow
        ? ObjectToCamelCasedProperties<ContactTableItem>(firstContactRow)
        : null;
}

export async function insertContact(contact: ContactUpsertDto, txn?: typeof knex): Promise<number> {
    if (!isContactUpsertDto(contact)) {
        throw new Error('Invalid contact DTO given');
    }
    const [first] = await getKnexInstance(txn)
        .insert<SnakeCasedProperties<ContactUpsertDto>>(ObjectToSnakeCasedProperties<ContactUpsertDto>(contact))
        .returning('id') as Pick<ContactTableItem, 'id'>[];

    return first.id;
}

export async function updateContact(id: Contact['id'], contact: ContactUpsertDto, txn?: typeof knex): Promise<void> {
    if (!isContactUpsertDto(contact)) {
        throw new Error('Invalid contact DTO given');
    }
    await getKnexInstance(txn)
        .update(ObjectToSnakeCasedProperties<Omit<ContactDto, 'id'>>(contact))
        .where({ id });
}

export async function deleteContact(id: Contact['id'], txn?: typeof knex): Promise<void> {
    await getKnexInstance(txn).where({ id }).delete();
}

export async function listContacts(where = {} as ContactDto, fields = ContactFields, txn?: typeof knex): Promise<Contact[]> {
    const qb = fields.reduce((queryBuilder, col) => {
        return queryBuilder.select(`c.${col}`);
    }, getKnexInstance(txn));

    const results: ContactTableItem[] = await qb.where(where).from<ContactTableItem>({ c: 'contacts' });
    return results.map((record) => ObjectToCamelCasedProperties(record));
}

//#endregion
```

#### Advantages of This Approach

1. **Type Safety**:

   - By using TypeScript and Zod, we ensure that our data structures are strictly typed. This reduces the risk of runtime errors and improves code reliability.

2. **Consistent Naming Conventions**:

   - The utility functions `CamelToSnakeCase` and `SnakeToCamelCase` ensure that object keys are consistently formatted, facilitating the interaction between JavaScript (camelCase) and SQL databases (snake\_case).

3. **Reusability and Maintainability**:

   - The modular design, with utility functions and well-defined schemas, makes the codebase easier to maintain and extend. Adding new features or modifying existing ones becomes straightforward.

4. **Clear Separation of Concerns**:

   - The code is divided into logical sections, such as tools, domain definitions, and repository functions. This separation makes the code easier to understand and manage.

5. **Improved Validation**:

   - Using Zod for schema validation ensures that data conforms to the expected formats, catching errors early in the development process.

6. **Efficient Database Queries**:

   - Knex.js provides a powerful query-building mechanism, and our approach ensures that queries are type-safe and optimized for performance.

#### Conclusion

This approach leverages the strengths of TypeScript, Zod, and Knex.js to create a robust, maintainable, and type-safe data handling layer. By ensuring consistent naming conventions and thorough validation, we can build reliable applications that are easier to develop and maintain.

This article should provide you with a solid foundation to implement similar techniques in your own projects, enhancing the quality and reliability of your code.
